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

## Documentation
### View Class
![View-Class](/Documentation/CPBattleBots-ViewClass.png "View Class")
This is the UML documentation of the View class. 
The View class represents part of th user app interface with the main View being JoystickModeView.
JoystickModeView utilizes MovementJoystickView, RotationJoystickView, and ButtonView for the main view.
Both MovementJoystickView and RotationJoystickView call the Dash view for the outline of the maximum range of the joystick.

### BluetoothManager Class
![BluetoothManager-Class](/Documentation/CPBattleBots-BluetoothManagerClass.png "BluetoothManager Class")
This is the UML documentation of the BluetoothManager class. 
The BluetoothManager class uses the Core Bluetooth framework to communicate with Bluetooth Low Energy devices.
BluetoothManager has two extensions for the CBPeripheralDelegate protocol and the CBCentralManagerDelegate protocol.
In order for the app to build on your system, modify the Info.plist file with the NSBluetoothAlwaysUsageDescription with description keys for the types of data it needs to access in order to access the Core Bluetooth APIs.

### PreviewProvider Class
![PreviewProvider-Class](/Documentation/CPBattleBots-PreviewProviderClass.png "PreviewProvider Class")
This is the UML documentation of the PreviewProvider class.
The PreviewProvider class produces View previews of a given class in Xcode

### Written in SwiftUI using Xcode for MacOS
