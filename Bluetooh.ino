/*
******************************************************************************************
  Sistema Integrado de Sensores com Bluetooth
  Version: V 1.0 
  Date: 12/02/2025
  
  Descrição: Este programa integra múltiplos sensores e comunicação Bluetooth
             Sensores incluídos:
             - GPS NEO-6M
             - DS18B20 (Temperatura)
             - MAX30102 (Batimento Cardíaco)
             - LED interno para status
             
  Pinout:
  ESP32   GPIO2  -> LED BUILTIN
  GPIO4   -> DS18B20
  GPIO16  -> GPS RX
  GPIO17  -> GPS TX
  SDA (21)-> MAX30102 SDA
  SCL (22)-> MAX30102 SCL
******************************************************************************************  
*/

#include <Arduino.h>
#include <BluetoothSerial.h>
#include <TinyGPS++.h>
#include <OneWire.h>
#include <DallasTemperature.h>
#include <Wire.h>
#include "MAX30105.h"
#include "heartRate.h"
#include <freertos/FreeRTOS.h>
#include <freertos/task.h>
#include <freertos/queue.h>

// Definições e Constantes
#define LED_BUILTIN 2
#define ONE_WIRE_BUS 4
#define GPS_BAUD 9600
#define RXD2 16
#define TXD2 17
#define Q_SIZE 64

// Estruturas de dados
typedef struct {
  String sensor;
  float value;
} SensorData;

// Filas FreeRTOS
QueueHandle_t dataQueue = NULL;

// Objetos globais
BluetoothSerial SerialBT;
TinyGPSPlus gps;
HardwareSerial gpsSerial(2);
OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature tempSensor(&oneWire);
MAX30105 particleSensor;

// Variáveis globais
unsigned long lastTempRead = 0;
const unsigned long tempInterval = 5000;
byte rates[4]; // Para cálculo de BPM
byte rateSpot = 0;
float beatAvg = 0;

// Protótipos de tarefas
void taskBluetooth(void *pvParameters);
void taskGPS(void *pvParameters);
void taskTemperature(void *pvParameters);
void taskHeartRate(void *pvParameters);
void taskStatusLED(void *pvParameters);

void setup() {
  Serial.begin(115200);
  SerialBT.begin("SENSORES_ESP32");
  
  // Inicializa hardware
  pinMode(LED_BUILTIN, OUTPUT);
  gpsSerial.begin(GPS_BAUD, SERIAL_8N1, RXD2, TXD2);
  tempSensor.begin();
  
  // Inicializa MAX30102
  if (particleSensor.begin(Wire, I2C_SPEED_FAST)) {
    particleSensor.setup();
    particleSensor.setPulseAmplitudeRed(0x1F);
    particleSensor.setSampleRate(100); // 400 amostras/segundo
    particleSensor.setADCRange(4096);  // Faixa máxima do ADC
    // Aumente o tempo de integração
    particleSensor.setPulseWidth(411);  // Maior tempo = mais sensibilidade
  }

  // Cria fila
  dataQueue = xQueueCreate(Q_SIZE, sizeof(SensorData));

  // Cria tarefas
  xTaskCreatePinnedToCore(taskBluetooth, "Bluetooth", 4096, NULL, 1, NULL, 0);
  xTaskCreatePinnedToCore(taskGPS, "GPS", 4096, NULL, 1, NULL, 0);
  xTaskCreatePinnedToCore(taskTemperature, "Temp", 4096, NULL, 1, NULL, 0);
  xTaskCreatePinnedToCore(taskHeartRate, "Heart", 4096, NULL, 1, NULL, 0);
  xTaskCreatePinnedToCore(taskStatusLED, "LED", 1024, NULL, 1, NULL, 1);

  vTaskDelete(NULL); // Elimina tarefa setup
}

void loop() {}

// Tarefas ---------------------------------------------------------------
void taskBluetooth(void *pvParameters) {
  SensorData data;
  for(;;) {
    if(xQueueReceive(dataQueue, &data, portMAX_DELAY) == pdPASS) {
      String msg = String(data.sensor) + ": " + String(data.value) + "\n";
      SerialBT.print(msg);
      Serial.print(msg);
    }
  }
}

void taskGPS(void *pvParameters) {
  SensorData data;
  data.sensor = "GPS";
  
  for(;;) {
    while(gpsSerial.available() > 0) {
      if(gps.encode(gpsSerial.read())) {
        if(gps.location.isUpdated()) {
          data.value = gps.location.lat();
          xQueueSend(dataQueue, &data, 0);
          data.value = gps.location.lng();
          xQueueSend(dataQueue, &data, 0);
        }
      }
    }
    vTaskDelay(pdMS_TO_TICKS(100));
  }
}

void taskTemperature(void *pvParameters) {
  SensorData data;
  data.sensor = "TEMP";
  
  for(;;) {
    if(millis() - lastTempRead >= tempInterval) {
      tempSensor.requestTemperatures();
      data.value = tempSensor.getTempCByIndex(0);
      xQueueSend(dataQueue, &data, 0);
      lastTempRead = millis();
    }
    vTaskDelay(pdMS_TO_TICKS(100));
  }
}

void taskHeartRate(void *pvParameters) {
  SensorData data;
  data.sensor = "BPM";
  long lastBeat = 0;
  
  for(;;) {
    long irValue = particleSensor.getIR();
    
    if(irValue > 15000) {
      if(checkForBeat(irValue)) {
        long delta = millis() - lastBeat;
        lastBeat = millis();
        
        float bpm = 60 / (delta / 1000.0);
        if(bpm > 20 && bpm < 255) {
          rates[rateSpot++] = (byte)bpm;
          rateSpot %= 4;
          
          beatAvg = 0;
          for(byte x = 0; x < 4; x++) beatAvg += rates[x];
          beatAvg /= 4;
          
          data.value = beatAvg;
          xQueueSend(dataQueue, &data, 0);
        }
      }
    }
    vTaskDelay(pdMS_TO_TICKS(10));
  }
}

void taskStatusLED(void *pvParameters) {
  for(;;) {
    digitalWrite(LED_BUILTIN, !digitalRead(LED_BUILTIN));
    vTaskDelay(pdMS_TO_TICKS(500));
  }
}

