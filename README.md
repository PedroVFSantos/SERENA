# SERENA - Health Monitoring App
![serena](https://github.com/user-attachments/assets/188b718e-b398-48e9-bf1b-224f248d2f6a)


FIGMA:
<img width="3824" height="4531" alt="grupo05" src="https://github.com/user-attachments/assets/21642f22-e286-4895-8238-88257736ff1a" />


## Overview
SERENA is a comprehensive health monitoring application built with Flutter that tracks various vital signs including heart rate, stress levels, step count, and body temperature. The app features real-time monitoring, data visualization, and alert systems for critical health parameters.

## Prerequisites
- Flutter 3.27.1
- JDK 17
- Android Studio / VS Code

## Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.2.2
  fl_chart: ^0.66.2
```

## Features

### Authentication System
- User registration and login functionality
- Secure data storage using SharedPreferences
- Email and password validation
- Persistent session management

### Home Dashboard
- Grid layout with four main monitoring categories
- Intuitive navigation with icon-based cards
- Responsive design adapting to different screen sizes

### Heart Rate Monitoring
- Real-time heart rate simulation and tracking
- Dynamic line chart visualization using fl_chart
- Color-coded warnings for dangerous heart rate levels
- Statistical analysis including:
  - Maximum heart rate
  - Minimum heart rate
  - Average heart rate
- Automated alerts for dangerous heart rate levels (>160 bpm)

### Temperature Monitoring
- Real-time body temperature tracking
- Range: 35.0°C - 40.0°C
- Visual thermometer representation
- Dehydration monitoring system:
  - Percentage-based hydration level
  - Progressive dehydration simulation
  - Critical alerts at 20% hydration
  - Visual progress indicator

### Additional Health Metrics
- Stress level monitoring
- Step counter
- Basic health status indicators

## Technical Implementation

### Color Scheme
- Primary Color: `0xFFD90429`
- Background: White
- Accent Colors: Various shades for different health states

### Navigation
- Route-based navigation system
- Named routes for all main screens
- Consistent back navigation

### Data Visualization
- Line charts for heart rate
- Progress indicators for hydration
- Icon-based status indicators
- Dynamic color coding based on health parameters

### Alert System
- Modal dialogs for critical warnings
- Bottom sheets for statistics
- Snackbar notifications for user feedback

## Code Structure

### Main Components

1. `HealthApp` (Root Widget)
   - MaterialApp configuration
   - Theme settings
   - Route definitions

2. `HomePage`
   - Grid layout with health monitoring cards
   - Navigation to specific monitoring pages

3. `LoginPage` & `SignupPage`
   - User authentication
   - Form validation
   - SharedPreferences integration

4. `HeartRatePage`
   - Timer-based data simulation
   - LineChart implementation
   - Statistical analysis
   - Warning system

5. `TemperaturePage`
   - Temperature simulation
   - Dehydration monitoring
   - Alert system
   - Visual feedback

### State Management
- StatefulWidget implementation for dynamic data
- Timer-based updates
- SharedPreferences for persistent storage

### UI Components
- Custom cards
- Charts and graphs
- Progress indicators
- Alert dialogs
- Modal bottom sheets

## Security Features
- Password masking
- Input validation
- Secure local storage
- Session management

## Performance Considerations
- Efficient timer management
- Resource cleanup in dispose methods
- Optimized rebuilds
- Memory-efficient data structures

## Future Enhancements
- Real sensor integration
- Cloud data synchronization
- Historical data analysis
- User profile customization
- Advanced health metrics
- Export functionality

## Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

## License
This project is licensed under the MIT License - see the LICENSE file for details.
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)


