# iOS Bluetooth Controller for Mecanum Drive Battle Robot
## Versions
### Full App
Two joysticks control translation and rotation of the bot.
There are three buttons on the bottom that turn on/off weapons, enable/disable field orientation, or kill power to the bot.
The top shows the current bluetooth connection status with the bot.

### Lite (Dual Joysticks)
This is an older version of the full app used for testing.
Two joysticks control translation and rotation of the bot.
There is a button ability bar that could be used for turning on/off weapons, killing power to the bot, etc.
There is a mode switch button bar to switch between the modes which was in development
(originally a joystick mode, gesture-based mode, and a hybrid mode combining both joystick and gesture mode).

## Installation
Make sure your iOS device has Developer Mode enabled under Settings -> Privacy & Security -> Developer Mode.
Also ensure that your Apple ID is specified in the Account preferences in Xcode and that a valid team is specifed in the project's project’s Signing & Capabilities pane.
Connect the iOS device to a MacBook with Xcode installed with the iOS device on and unlocked.
On the top center of the screen in the toolbar, select the iOS device to build the application onto. 
By default, it should build onto "Any iOS Device (arm64)".
On the top left, select the Run button in the toolbar to "Start the active scheme".
The application should now be installed on the iOS device.

More information about running the app on an iOS device is available [here](https://developer.apple.com/documentation/xcode/running-your-app-in-simulator-or-on-a-device)

### IMPORTANT:
Regular Apple user accounts can sign an application onto their device for 7 days. 
After 7 days, the app needs to be rebuilt onto the iOS device from Xcode.
Apple Developer accounts in the Apple Developer Program can have builds remain active for 90 days after install. 

More information about the Apple Developer Program is available [here](https://developer.apple.com/programs/).

## Usage
![App](/Documentation/CPBattleBots-App.png "App")
### 1. Connection Status
Ensure that the iOS device has bluetooth enabled and that it is connected to the device "ESP32_BLE".
If the device is not connected and cannot be found in settings, install the [Bluefruit Connect](https://apps.apple.com/us/app/bluefruit-connect/id830125974) app to search for Bluetooth devices around you.

Possible connection statuses are:

1. CONNECTED

2. DISCONNECTED

3. SEARCHING

4. CONNECTING

5. ERROR

### 2. Movement Joystick
This joystick on the left side of the scren handles translation of the bot. 
Above the joystick are the magnitude and angle measured values of the joystick from the zero origin.
The max magnitude is a value of 50.
Moving the bot foward has a joystick angle of 0/360 degrees.
Moving the bot backwards has a joystick angle of 180 degrees.
Moving the bot to the right has a joystick angle of 90 degrees.
Moving the bot to the left has a joystick angle of 270 degrees.

### 3. Rotation Joystick
This joystick on the right side of the screenhandles rotation of the bot. 
Above the joystick are the magnitude measured value and rotation direction of the joystick from the zero origin.
The max magnitude is a value of 50.
The rotation directions are either clockwise, counterclockwise, or no rotation

### 4. Buttons
There are 3 buttons at the bottom of the screen: Weapon, Field Orientation, Power

#### Weapon
This button turns the weapon on or off. At default, the weapon is off.

#### Field Orientation
This button enables or disables field orientation controls. At default, field orientated controls is enabled.

#### Power
This button powers off the bot. At defualt, the bot is powered on.

## Documentation
### iOS App Flowchart
![App-Flowchart](/Documentation/AppFlowchart.png "App Flowchart")
This is a flowchart of how the overall iOS app functions. 
The main view window has separate movement joystick, rotation joystick, and button components.
It will then calculate the joystick angle and magnitude and send that data to back to the main view window and to Bluetooth Manager.
Bluetooth Manager will send the Bluetooth connection status to the main view window.

---
### View Class
![View-Class](/Documentation/CPBattleBots-ViewClass.png "View Class")
This is the UML documentation of the View class. 
The View class represents part of th user app interface with the main View being JoystickModeView.
JoystickModeView utilizes MovementJoystickView, RotationJoystickView, and ButtonView for the main view.
Both MovementJoystickView and RotationJoystickView call the Dash view for the outline of the maximum range of the joystick.

---
### BluetoothManager Class
![BluetoothManager-Class](/Documentation/CPBattleBots-BluetoothManagerClass.png "BluetoothManager Class")
This is the UML documentation of the BluetoothManager class. 
The BluetoothManager class uses the Core Bluetooth framework to communicate with Bluetooth Low Energy devices.
BluetoothManager has two extensions for the CBPeripheralDelegate protocol and the CBCentralManagerDelegate protocol.
In order for the app to build on your system, modify the Info.plist file with the NSBluetoothAlwaysUsageDescription with description keys for the types of data it needs to access in order to access the Core Bluetooth APIs.

![BluetoothManager-Flowchart](/Documentation/BluetoothManagerFlowchart.png "BluetoothManager Flowchart")
This is a flowchart of how the Bluetooth Manager functions. 
First it will check if the Bluetooth is enabled for the iOS device.
If so it will start scanning for Bluetooth peripherals.
When it discovers the bot, it will attempt to connect.
After connecting it will try to find the Bluetooth service UUID.
If it finds it, it will look for the characteristics of the service UUID and then send joystick and button data to their respective characteristic UUID.
If the connection fails, it will check if either there was a disconnect or it failed to connect.
From there it will start a reconnection timer and start the scan for Bluetooth peripherals again.

---
### PreviewProvider Class
![PreviewProvider-Class](/Documentation/CPBattleBots-PreviewProviderClass.png "PreviewProvider Class")
This is the UML documentation of the PreviewProvider class.
The PreviewProvider class produces View previews of a given class in Xcode

---
### Written in SwiftUI using Xcode for MacOS
