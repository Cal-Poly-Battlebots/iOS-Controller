//
//  JoyStickModeView.swift
//  BattleBotJoySticks
//
//  Created by Aaron Rosen on 10/1/23.
//



import SwiftUI

// ----------------------------------------------------------------
// Dual Joystick
//
enum JoystickType {
    case left
    case right
}

struct JoystickView: View {
    @Binding var joystickPosition: CGPoint
    let joystickType: JoystickType

    var body: some View {
        ZStack {
                // Create the joystick circle
                Circle()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.gray.opacity(0.4))
                    .position(joystickPosition)
                    .overlay(
                        Circle()
                            .stroke(Color.gray.opacity(0.4), lineWidth: 5)
                            .frame(width: 57, height: 57)
                            .position(.zero)
                    )
                    // What happens when circle is dragged
                    .gesture(
                        DragGesture()
                        .onChanged { value in
                            // Update joystick position based on drag
                            let newPosition = value.location
                            let distance = sqrt(pow(newPosition.x, 2) + pow(newPosition.y, 2))
                            let maxDistance: CGFloat = 150 // Maximum range
    
                            if distance <= maxDistance {
                                joystickPosition = newPosition
                            } else {
                                // Limit joystick movement within the maximum range
                                let angle = atan2(newPosition.y, newPosition.x)
                                joystickPosition = CGPoint(x: maxDistance * cos(angle), y: maxDistance * sin(angle))
                            }
                        }
                        // When joystick is released
                        .onEnded { _ in
                            // Reset the joystick position when dragging ends
                            joystickPosition = .zero
                        }
                )
            
            // Dashes representing the maximum range (North, South, East, West)
            Group {
                Dash().rotationEffect(.degrees(0)).position(.zero).offset(y: -150)
                Dash().rotationEffect(.degrees(90)).position(.zero).offset(x: 150)
                Dash().rotationEffect(.degrees(180)).position(.zero).offset(y: 150)
                Dash().rotationEffect(.degrees(-90)).position(.zero).offset(x: -150)
            }
        }
        .frame(width: 30, height: 30)
    }

    private func updateJoystickPosition(_ newPosition: CGPoint) {
        let distance = sqrt(pow(newPosition.x, 2) + pow(newPosition.y, 2))
        let maxDistance: CGFloat = 150 // Maximum range

        if distance <= maxDistance {
            joystickPosition = newPosition
        } else {
            let angle = atan2(newPosition.y, newPosition.x)
            joystickPosition = CGPoint(x: maxDistance * cos(angle), y: maxDistance * sin(angle))
        }
    }
}

struct Dash: View {
    var body: some View {
        Rectangle()
            .frame(width: 2, height: 10)
            .foregroundColor(.gray.opacity(0.4))
    }
}

struct JoystickModeView: View {
    @State private var timer: Timer?

    @State private var joystickPositionL: CGPoint = .zero
    @State private var joystickPositionR: CGPoint = .zero
    
    @ObservedObject var abilityBarViewModel: AbilityBarViewModel
    @ObservedObject var navigationBarViewModel: NavigationBarViewModel

    let safeAreaBorder: CGFloat = 20.0

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Movement Joystick Angle: \(String(format: "%.2f", joystickAngle(joystickType: .left).degrees))")
                                    .font(.title2)
                                Text("Movement Joystick Magnitude: \(String(format: "%.2f", joystickMagnitude(joystickType: .left)))")
                                    .font(.title2)
                                Text("")
                            }
                        }
                        Spacer()
                        Spacer()
                        Spacer()
                        JoystickView(joystickPosition: $joystickPositionL, joystickType: .left)
                            .frame(width: 100, height: 100)
                            .padding([.leading, .trailing], safeAreaBorder + 100)
                        Spacer()
                    }
                    .padding([.leading, .trailing], safeAreaBorder)
                    
                    VStack(alignment: .trailing) {
                        HStack {
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("Rotation Joystick Angle: \(String(format: "%.2f", joystickAngle(joystickType: .right).degrees))")
                                    .font(.title2)
                                Text("Rotation Joystick Magnitude:  \(String(format: "%.2f", joystickMagnitude(joystickType: .right)))")
                                    .font(.title2)
                            }
                        }
                        Spacer()
                        Spacer()
                        Spacer()
                        JoystickView(joystickPosition: $joystickPositionR, joystickType: .right)
                            .frame(width: 100, height: 100)
                            .padding([.leading, .trailing], 100)
                        Spacer()
                    }
                    .padding([.leading, .trailing], safeAreaBorder)
                }
                
                
                HStack {
                    Spacer()
                    VStack {
                        AbilityBarView(abilityBar: $navigationBarViewModel.navigationBar)
                        Text("Mode Switch")
                            .font(.title3)
                    }
                    Spacer()
                    VStack {
                        AbilityBarView(abilityBar: $abilityBarViewModel.abilityBar)
                        Text("Ability Bar")
                            .font(.title3)
                    }
                    Spacer()
                }
                .padding(.top, 20)
            }
            .navigationBarTitle("Joystick Mode")
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
            let joyAngleLeft = joystickAngle(joystickType: .left).degrees
            let joyMagLeft = joystickMagnitude(joystickType: .left)
            
            let joyAngleRight = joystickAngle(joystickType: .right).degrees
            let joyMagRight = joystickMagnitude(joystickType: .right)
            
            // Format the data as a string (you can adjust this based on your Bluetooth communication protocol)
            DispatchQueue.main.async {
                let dataToSend1 = "\(joyAngleLeft),\(joyMagLeft)"
                let dataToSend2 = "\(joyAngleRight),\(joyMagRight)"
                
                BluetoothManager.shared.sendData(dataToSend1, BluetoothManager.joystick_uuid.uuidString)
                BluetoothManager.shared.sendData(dataToSend2, BluetoothManager.swipe_uuid.uuidString)
                
            }
        }
    }


    // Stop sending Bluetooth data
    private func stopSendingBluetoothData() {
        // Invalidate the timer when the view disappears
        timer?.invalidate()
    }

    private func joystickAngle(joystickType: JoystickType) -> Angle {
        let joystickPosition: CGPoint
        switch joystickType {
        case .left:
            joystickPosition = joystickPositionL
        case .right:
            joystickPosition = joystickPositionR
        }

        var angle = atan2(joystickPosition.y, joystickPosition.x)
        angle += .pi / 2

        if angle < 0 {
            angle += 2 * .pi
        }
        if joystickMagnitude(joystickType: joystickType) < 2 {
            angle = 0
        }
        return Angle(radians: Double(angle))
    }

    private func joystickMagnitude(joystickType: JoystickType) -> CGFloat {
        let joystickPosition: CGPoint
        switch joystickType {
        case .left:
            joystickPosition = joystickPositionL
        case .right:
            joystickPosition = joystickPositionR
        }

        return sqrt(pow(joystickPosition.x, 2) + pow(joystickPosition.y, 2)) / 3
    }
}

struct JoystickModeView_Previews: PreviewProvider {
    static var previews: some View {
        let abilityBarViewModel = AbilityBarViewModel()
        let navigationBarViewModel = NavigationBarViewModel()
        return JoystickModeView(abilityBarViewModel: abilityBarViewModel, navigationBarViewModel: navigationBarViewModel)
    }
}

// ----------------------------------------------------------------
// Hybrid Mode for IMU testing
// Leave JoystickType and JoystickView uncommented when testing
//

//import SwiftUI
//
//struct HybridModeView: View {
//    @State private var currentFacingAngle = Angle(degrees: 0.0)
//    @State private var finalFacingAngle = Angle(degrees: 0)
//    @State private var timer: Timer?
//
//    @ObservedObject var abilityBarViewModel: AbilityBarViewModel
//    @ObservedObject var navigationBarViewModel: NavigationBarViewModel
//
//    @State private var joystickPosition: CGPoint = .zero
//
//    let safeAreaBorder: CGFloat = 20.0
//
//    var body: some View {
//        NavigationStack {
//            VStack{
//                HStack{
//                    VStack(alignment: .leading){
//                        HStack{
//                            VStack(alignment: .leading) {
//                                Text("Facing Angle: \(String(format: "%.2f", finalFacingAngle.degrees))")
//                                    .font(.title2)
//                                Text("Joystick Angle: \(String(format: "%.2f", joystickAngle().degrees))")
//                                    .font(.title2)
//                                Text("Joystick Magnitude: \(String(format: "%.2f", joystickMagnitude()))")
//                                    .font(.title2)
//                            }
//                            Spacer()
//                        }
//                        Spacer()
//                        Spacer()
//                        Spacer()
//                        JoystickView(joystickPosition: $joystickPosition, joystickType: .left)
//                        .frame(width: 100, height: 100)
//                        .padding([.leading, .trailing], safeAreaBorder + 100)
//                        Spacer()
//                    }
//                    .padding([.leading, .trailing], safeAreaBorder)
//
//                    // Swipe Zone
//                    RoundedRectangle(cornerRadius: 10.0)
//                        .fill(Color.indigo.opacity(0.2))
//                        .padding([.leading, .trailing], safeAreaBorder)
//                        .overlay(
//                            VStack{
//                                HStack {
//                                    Spacer()
//                                    // Visual Representation (top right corner) of what is happening to the Robot
//                                    RoundedRectangle(cornerRadius: 10.0)
//                                        .fill(Color.gray)
//                                        .frame(width: 100, height: 70)
//                                        .overlay(
//                                            Text("Claymore")
//                                                .foregroundColor(.white)
//                                                .font(.system(size: 14))
//                                        )
//                                        .padding([.leading, .trailing], safeAreaBorder + 30)
//                                        .padding([.top, .bottom], safeAreaBorder+20)
//                                        // Add rotation from RotationGesture in Swipe Zone
//                                        .rotationEffect(finalFacingAngle)
//                                }
//                                Spacer()
//                            }
//                        )
//                        .gesture(
//                            RotationGesture()
//                                .onChanged { angle in
//                                    // Add the currentFacingAngle to the finalFacingAngle to accumulate rotations
//                                    finalFacingAngle = currentFacingAngle + angle
//                                    // Make sure the angle is between 0 and 360 degrees
//                                    if finalFacingAngle.degrees < 0 {
//                                        finalFacingAngle = .degrees(360 + finalFacingAngle.degrees)
//                                    } else if finalFacingAngle.degrees >= 360 {
//                                        finalFacingAngle = .degrees(finalFacingAngle.degrees - 360)
//                                    }
//                                }
//                                .onEnded { angle in
//                                    currentFacingAngle = finalFacingAngle
//                                }
//                        )
//                }
//                HStack {
//                    Spacer()
//                    VStack {
//                        AbilityBarView(abilityBar: $navigationBarViewModel.navigationBar)
//                        Text("Mode Switch")
//                            .font(.title3)
//                    }
//                    Spacer()
//                    VStack {
//                        AbilityBarView(abilityBar: $abilityBarViewModel.abilityBar)
//                        Text("Ability Bar")
//                            .font(.title3)
//                    }
//                    Spacer()
//                }
//                .padding(.top, 20)
//            }
//            .navigationBarTitle("Hybrid Mode")
//            // Use onAppear to start sending data when the view appears
//            .onAppear {
//                startSendingBluetoothData()
//            }
//            // Use onDisappear to stop sending data when the view disappears
//            .onDisappear {
//                stopSendingBluetoothData()
//            }
//
//        }
//
//    }
//
//    // Start sending Bluetooth data
//    private func startSendingBluetoothData() {
//        // Start a timer to regularly send data over Bluetooth
//        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
//            // Convert angles to degrees and send over Bluetooth
//            let facingAngle = finalFacingAngle.degrees
//            let joyAngle = joystickAngle().degrees
//            let joyMag = joystickMagnitude()
//
//            // Format the data as a string (you can adjust this based on your Bluetooth communication protocol)
//            DispatchQueue.main.async {
//                let dataToSend1 = "\(joyAngle),\(joyMag)"
//                let dataToSend2 = "\(facingAngle), 50"
//
//                BluetoothManager.shared.sendData(dataToSend1, BluetoothManager.joystick_uuid.uuidString)
//                BluetoothManager.shared.sendData(dataToSend2, BluetoothManager.swipe_uuid.uuidString)
//
//            }
//        }
//    }
//
//    // Stop sending Bluetooth data
//    private func stopSendingBluetoothData() {
//        // Invalidate the timer when the view disappears
//        timer?.invalidate()
//    }
//
//    private func joystickAngle() -> Angle {
//        // Calculate the angle based on the joystick's position
//
//        var angle = atan2(joystickPosition.y, joystickPosition.x)
//
//        angle += .pi / 2
//
//        // Normalize the angle to be between 0 and 2*pi
//        if angle < 0 {
//            angle += 2 * .pi
//        }
//        if joystickMagnitude() < 2 {
//            angle = 0
//        }
//        return Angle(radians: Double(angle))
//    }
//
//    private func joystickMagnitude() -> CGFloat {
//        return sqrt(pow(joystickPosition.x, 2) + pow(joystickPosition.y, 2)) / 3
//    }
//
//}
//
//struct HybridModeView_Previews: PreviewProvider {
//    static var previews: some View {
//        let abilityBarViewModel = AbilityBarViewModel()
//        let navigationBarViewModel = NavigationBarViewModel()
//        return HybridModeView(abilityBarViewModel: abilityBarViewModel, navigationBarViewModel: navigationBarViewModel)
//    }
//}



// -------------------------------------------------------------------
// Original Joystick Mode Code by Aaron

//struct SwipeGestureView: View {
//    @Binding var swipePosition: CGPoint
//    @Binding var swipeMagnitude: CGFloat
//    @Binding var swipeAngleDegrees: CGFloat
//
//    var body: some View {
//        ZStack {
//            Color.clear // Use a clear background to cover the entire screen
//                .contentShape(Rectangle())
//                .frame(width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.width / 2)
//                .gesture(
//                    DragGesture(minimumDistance: 0)
//                        .onChanged { value in
//                            // Update swipe position based on drag gesture
//                            swipePosition = value.startLocation
//                            // Calculate magnitude and angle
//                            let xAxisValue = value.translation.width
//                            let yAxisValue = value.translation.height
//                            swipeMagnitude = min(sqrt(pow(xAxisValue / 5, 2) + pow(yAxisValue / 5, 2)), 50.0)
//                            
//                            let swipeAngle = atan2(yAxisValue, xAxisValue)
//                            swipeAngleDegrees = (270 + 180 + swipeAngle * 180 / .pi).truncatingRemainder(dividingBy: 360)
//                            // Send data to Bluetooth
//                            let dataToSend = "\(swipeAngleDegrees),\(swipeMagnitude)\n"
//                            BluetoothManager.shared.sendData(dataToSend, BluetoothManager.swipe_uuid.uuidString)
//                        }
//                        .onEnded { _ in
//                            // Reset swipe position when gesture ends
//                            swipePosition = .zero
//                            swipeMagnitude = 0.0
//                            swipeAngleDegrees = 0.0
//                            // Send data to Bluetooth to stop movement
//                            let dataToSend = "0.0,0.0\n"
//                            BluetoothManager.shared.sendData(dataToSend, BluetoothManager.swipe_uuid.uuidString)
//                        }
//                )
//                .background(Color.indigo.opacity(0.2))
//        }
//        .edgesIgnoringSafeArea(.all) // Make the overlay cover the entire screen
//    }
//}
//
//struct JoystickView: View {
//    @Binding var joystickPosition: CGPoint
//
//    var body: some View {
//        ZStack {
//            // Create the joystick circle
//            Circle()
//                .frame(width: 50, height: 50)
//                .foregroundColor(.gray.opacity(0.4))
//                .position(joystickPosition)
//                .overlay(
//                    Circle()
//                        .stroke(Color.gray.opacity(0.4), lineWidth: 5)
//                        .frame(width: 57, height: 57)
//                        .position(.zero)
//                )
//                // What happens when circle is dragged
//                .gesture(
//                    DragGesture()
//                    .onChanged { value in
//                        // Update joystick position based on drag
//                        let newPosition = value.location
//                        let distance = sqrt(pow(newPosition.x, 2) + pow(newPosition.y, 2))
//                        let maxDistance: CGFloat = 150 // Maximum range
//                        
//                        if distance <= maxDistance {
//                            joystickPosition = newPosition
//                        } else {
//                            // Limit joystick movement within the maximum range
//                            let angle = atan2(newPosition.y, newPosition.x)
//                            joystickPosition = CGPoint(x: maxDistance * cos(angle), y: maxDistance * sin(angle))
//                        }
//                    }
//                    // When joystick is released
//                    .onEnded { _ in
//                        // Reset the joystick position when dragging ends
//                        joystickPosition = .zero
//                    }
//            )
//            
//            Group {
//                // Dashes representing the maximum range (North, South, East, West)
//                Dash()
//                    .rotationEffect(.degrees(0))
//                    .position(.zero)
//                    .offset(y: -150)
//                
//                Dash()
//                    .rotationEffect(.degrees(90))
//                    .position(.zero)
//                    .offset(x: 150)
//                
//                Dash()
//                    .rotationEffect(.degrees(180))
//                    .position(.zero)
//                    .offset(y: 150)
//                
//                Dash()
//                    .rotationEffect(.degrees(-90))
//                    .position(.zero)
//                    .offset(x: -150)
//            }
//        }
//        .frame(width: 30, height: 30)
//    }
//}
//
//struct Dash: View {
//    var body: some View {
//        Rectangle()
//            .frame(width: 2, height: 10)
//            .foregroundColor(.gray.opacity(0.4))
//    }
//}
//
//struct JoystickModeView: View {
//    @State private var joystickPosition: CGPoint = .zero
//    @State private var xAxisValue: CGFloat = 0.0
//    @State private var yAxisValue: CGFloat = 0.0
//    @State private var joyStickAngle: CGFloat = 0.0
//    @State private var joyStickMagnitude: CGFloat = 0.0
//    @State private var joyStickAngleDegrees: CGFloat = 0.0
//    @State private var swipePosition: CGPoint = .zero
//    @State private var swipeMagnitude: CGFloat = 0.0
//    @State private var swipeAngleDegrees: CGFloat = 0.0
//    @State private var timer: Timer?
//    
//    @ObservedObject var abilityBarViewModel: AbilityBarViewModel
//    @ObservedObject var navigationBarViewModel: NavigationBarViewModel
//
//    var body: some View {
//        GeometryReader { geometry in
//            ZStack {
//                // Ability bar at the bottom, centered
//                AbilityBarView(abilityBar: $abilityBarViewModel.abilityBar)
//                    .padding(20)
//                    .position(x: geometry.size.width / 2, y: geometry.size.height - 40)
//
//                // Joystick at the bottom left
//                JoystickView(joystickPosition: $joystickPosition)
//                    .frame(width: 100, height: 100) // Adjust the size as needed
//                    .position(x: 170, y: geometry.size.height - 200)
//                
//                // SwipeView
//                SwipeGestureView(swipePosition: $swipePosition, swipeMagnitude: $swipeMagnitude, swipeAngleDegrees: $swipeAngleDegrees)
//                    .frame(width: geometry.size.width / 2, height: geometry.size.height) // Takes up the right half of the screen
//                    .position(x: geometry.size.width * 0.75, y: geometry.size.height / 2) // Centered vertically on the right side
//
//            }
//
//            Text("Joystick Angle: \(joyStickAngleDegrees), Magnitude: \(joyStickMagnitude)")
//            .font(.title)
//            .padding()
//            
//            
//            Text("Swipe Angle: \(swipeAngleDegrees), Swipe Magnitude: \(swipeMagnitude)")
//            .padding()
//            .padding()
//            .font(.title)
//            .padding()
//            .offset(x: -32)
//        }
//        .navigationBarTitle("Joystick Mode")
//        .onAppear {
//            // Start a Timer to update variables as fast as possible
//            self.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
//                // Update variables with joystick values
//                xAxisValue = joystickPosition.x
//                yAxisValue = joystickPosition.y
//                // Calculate magnitude and angle
//                joyStickMagnitude = sqrt(pow(xAxisValue, 2) + pow(yAxisValue, 2)) / 2.4
//                
//                // Calculate angle in radians
//                joyStickAngle = atan2(yAxisValue, xAxisValue)
//                
//                // Convert radians to degrees (0-360, clockwise)
//                joyStickAngleDegrees = (270 + 180 + joyStickAngle * 180 / .pi).truncatingRemainder(dividingBy: 360)
//                
//                // Send data to Bluetooth on the main thread
//                DispatchQueue.main.async {
//                    let dataToSend = "\(joyStickAngleDegrees),\(joyStickMagnitude)\n"
//                    BluetoothManager.shared.sendData(dataToSend, BluetoothManager.joystick_uuid.uuidString)
//                }
//            }
//        }
//        .onDisappear {
//            self.timer?.invalidate()
//        }
//    }
//}
