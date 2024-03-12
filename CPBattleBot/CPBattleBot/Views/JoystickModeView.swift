//
//  JoyStickModeView.swift
//  CP BattleBot



import SwiftUI


enum JoystickType {
    case left
    case right
}

struct JoystickModeView: View {
    // The main content view window struct of the app
    @State private var timer: Timer?
    @State private var joystickPositionL: CGPoint = .zero
    @State private var joystickPositionR: CGPoint = .zero
    @State var fieldOrientationOffset: Double = 0
    @ObservedObject var buttons: ButtonViewModel
    @StateObject var bluetoothManager = BluetoothManager.shared
    

    let safeAreaBorder: CGFloat = 20.0

    var body: some View {
        NavigationStack {
            VStack{
                // Print Connection status at top of scren
                Text(bluetoothManager.peripheralStatus.rawValue.uppercased())
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .font(.title)
                
                // Break the view into a left half (movement) and a right half (rotation)
                HStack {
                    // Left half (movement)
                    VStack(alignment: .leading) {
                        HStack {
                            // Print Movement Joystick data
                            VStack(alignment: .leading) {
                                Text("Movement Angle: \(String(format: "%.2f", joystickAngle(joystickType: .left).degrees))")
                                    .font(.title2)
                                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                Text("Movement Magnitude: \(String(format: "%.2f", joystickMagnitude(joystickType: .left)))")
                                    .font(.title2)
                                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                            }
                        }
                        // Print Movement joystick
                        Spacer(minLength: 300.0)
                        MovementJoystickView(joystickPosition: $joystickPositionL)
                            .frame(width: 100, height: 100)
                            .padding([.leading, .trailing], safeAreaBorder + 100)
                        Spacer()
                    }
                    // Add some padding on left and right of view
                    .padding(.leading, safeAreaBorder)
                    
                    // Right half (rotation)
                    VStack(alignment: .trailing) {
                        HStack {
                            Spacer()
                            // Print Rotation Joystick data
                            VStack(alignment: .trailing) {
                                Text("Rotation Magnitude:  \(String(format: "%.2f", joystickMagnitude(joystickType: .right)))")
                                    .font(.title2)
                                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                // Print either rotating clockwise, counterclockwise, or no rotation
                                // Adjust "No Rotation" sensitivity by adjust 3 which is the magnitude of the rotation out of 50
                                Text("\(joystickMagnitude(joystickType: .right) > 3 ? (joystickAngle(joystickType: .right).degrees <= 180 ? "Clockwise" : "Counterclockwise") : "No Rotation")")
                                    .font(.title2)
                                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                            }
                        }
                        Spacer(minLength: 300.0)
                        // Print Rotation joystick
                        RotationJoystickView(joystickPosition: $joystickPositionR)
                            .frame(width: 100, height: 100)
                            .padding([.leading, .trailing], safeAreaBorder + 120)
                        Spacer()
                    }
                    // Add some padding on left and right of view
                    .padding(.trailing, safeAreaBorder)
                }
                

                // Vertical stack for items at the bottom of the screen
                VStack {
                    
                    // Field orientation offset slider
                    Text("Field Orientation Offset")
                        .font(.title3)
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        .foregroundStyle(.black)
                    Text("Offset: \(String(format: "%.2f", fieldOrientationOffset))")
                    Slider(value: $fieldOrientationOffset, in: -180...180, step: 1)
                        .tint(Color.green)
                        .padding(.horizontal, safeAreaBorder + (UIScreen.main.bounds.width / 4))
                        .padding(.bottom, 5)
                    // Reset button to set field orientation offset back to zero
                    Button("Reset") {
                        self.fieldOrientationOffset = 0
                    }
                    .padding(.bottom, 40)
                    .fontWeight(.bold)
                    
                    // Button View with weapon, field orientation offset, and power buttons
                    ButtonView(button: $buttons.inputButtons)
                        .padding(.bottom, safeAreaBorder + 30)
                }

                

            }
            // Use onAppear to start sending data when the view appears
            .onAppear {
                startSendingBluetoothData()
            }
            // Use onDisappear to stop sending data when the view disappears
            .onDisappear {
                stopSendingBluetoothData()
            }

        }

    }
    
    // Start sending Bluetooth data
    private func startSendingBluetoothData() {
        // Start a timer to regularly send data over Bluetooth
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            // Convert angles to degrees and send over Bluetooth
            let joyAngleRight = joystickAngle(joystickType: .right).degrees
            let joyMagRight = joystickMagnitude(joystickType: .right)
            
            var joyAngleLeft = joystickAngle(joystickType: .left).degrees
            let joyMagLeft = joystickMagnitude(joystickType: .left)
            
            // If there is a field orienation offset, ensure that the bot is sending an angle of 0 when the magnitude is near 0.
            if (joyMagLeft < 1)
            {
                joyAngleLeft = 0
            }
            
            // Format the data to send (Data1 = Movement UUID, Data2 = Rotation UUID)
            let moveData = "\(joyAngleLeft),\(joyMagLeft)"
            let rotateData = "\(joyAngleRight),\(joyMagRight)"
            
            // Convert inputButtons array to a string of 1s and 0s
            let buttonsData = buttons.inputButtons.map { $0 ? "1" : "0" }.joined()
            
            // Send bluetooth data
            bluetoothManager.sendData(moveData, movement_uuid.uuidString)
            bluetoothManager.sendData(rotateData, rotation_uuid.uuidString)
            bluetoothManager.sendData(buttonsData, button_uuid.uuidString)
            
        }
    }

    // Stop sending Bluetooth data
    private func stopSendingBluetoothData() {
        // Invalidate the timer when the view disappears
        timer?.invalidate()
    }

    private func joystickAngle(joystickType: JoystickType) -> Angle {
        // Determine the joystick angle based on the joystick type
        let joystickPosition: CGPoint
        
        // Check if it is the right joystick (rotation) or left joystick (movement)
        switch joystickType {
        case .left:
            joystickPosition = joystickPositionL
        case .right:
            joystickPosition = joystickPositionR
        }

        // Calculate angle
        var angle = atan2(joystickPosition.y, joystickPosition.x)
        angle += .pi / 2
        
        if (buttons.inputButtons[1])
        {
            let offsetRadians = fieldOrientationOffset * (.pi/180)
            angle = angle + offsetRadians
        }

        // Limit angle from 0 to 2pi
        if angle < 0 {
            angle += 2 * .pi
        }
        
        // Ensure that the bot is sending an angle of 0 when the magnitude is near 0
        if joystickMagnitude(joystickType: joystickType) < 1 {
            angle = 0
        }
        
        // Return angle in radians
        return Angle(radians: Double(angle))
    }

    private func joystickMagnitude(joystickType: JoystickType) -> CGFloat {
        // Determine the joystick magnitude based on the joystick type
        let joystickPosition: CGPoint
        
        // Check if it is the right joystick (rotation) or left joystick (movement)
        switch joystickType {
        case .left:
            joystickPosition = joystickPositionL
        case .right:
            joystickPosition = joystickPositionR
        }
        
        // Calculate magnitude and limit to max of 50
        return sqrt(pow(joystickPosition.x, 2) + pow(joystickPosition.y, 2)) / 3
    }
}



struct JoystickModeView_Previews: PreviewProvider {
    static var previews: some View {
        let buttonViewModel = ButtonViewModel()
        return JoystickModeView(buttons: buttonViewModel)
    }
}
