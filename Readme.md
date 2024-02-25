# Notifications Core Data

## Overview
Notifications Core Data is a SwiftUI iOS application designed to let users create custom notifications with specific times, days, and messages. These notifications are then scheduled to trigger at the assigned day and time. The app stores each notification's unique identifier in Core Data, allowing for later deletion of scheduled notifications. This project emphasizes on Core Data integration with the UserNotifications framework to offer a seamless and productive user experience.

![notifications-core-data screen capture](screen-capture/notifications-core-data.gif)

## Features
- **Custom Notification Scheduling**: Schedule notifications for specific times and days with custom messages.
- **Core Data Integration**: Persistently store notification identifiers in Core Data for later access and modification.
- **Dynamic Notification Management**: Users can create, view, and delete scheduled notifications directly from the app.

## Requirements
- iOS 16.4+
- Xcode 13.0+
- Swift 5

## Installation
Download or clone the repository to your local machine. Open the `notifications-core-data.xcodeproj` file in Xcode. Make sure your development setup matches the project's requirements for a smooth running experience.

## Usage
The application provides a user-friendly interface for scheduling new notifications and managing existing ones. Upon first launch, users are prompted to grant notification permissions. Once granted, users can:

- Schedule new notifications specifying the time, type (daily or weekly), day (if weekly), and custom message.
- View a list of all scheduled notifications, displaying their time, type, day (if applicable), and message.
- Delete any scheduled notification with a simple swipe action.

### Scheduling a Notification
Utilize the `ViewModel` class for scheduling notifications. This class interfaces with `UNUserNotificationCenter` to manage notification permissions and scheduling based on user inputs.

### Core Data Integration
The app uses Core Data to store notification identifiers (`notificationID`). This allows the app to fetch, update, or delete specific notifications based on user actions.

## Permissions Overview
The app requires notification permissions to schedule and send notifications. It prompts the user for permission on first launch or when attempting to schedule a notification without prior permission granted.

## License
This project is made available under the MIT license.



