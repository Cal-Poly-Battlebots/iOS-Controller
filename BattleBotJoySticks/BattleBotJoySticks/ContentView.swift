//
//  ContentView.swift
//  BattleBotJoySticks
//
//  Created by Aaron Rosen on 10/1/23.
//

import SwiftUI

struct SwipeGestureView: View {
    @Binding var swipePosition: CGPoint
    @Binding var swipeMagnitude: CGFloat
    @Binding var swipeAngleDegrees: CGFloat

    var body: some View {
        ZStack {
            Color.clear // Use a clear background to cover the entire screen
                .contentShape(Rectangle())
                .frame(width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.width / 2)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            // Update swipe position based on drag gesture
                            swipePosition = value.startLocation
                            // Calculate magnitude and angle
                            let xAxisValue = value.translation.width
                            let yAxisValue = value.translation.height
                            swipeMagnitude = min(sqrt(pow(xAxisValue / 5, 2) + pow(yAxisValue / 5, 2)), 50.0)
                            swipeAngleDegrees = (360 + atan2(xAxisValue, -yAxisValue) * 180 / .pi).truncatingRemainder(dividingBy: 360)
                            // Send data to Bluetooth
                            let dataToSend = "\(swipeAngleDegrees),\(swipeMagnitude)"
                            BluetoothManager.shared.sendData(dataToSend, BluetoothManager.swipe_uuid)
                        }
                        .onEnded { _ in
                            // Reset swipe position when gesture ends
                            swipePosition = .zero
                            swipeMagnitude = 0.0
                            swipeAngleDegrees = 0.0
                            // Send data to Bluetooth to stop movement
                            let dataToSend = "0.0,0.0"
                            BluetoothManager.shared.sendData(dataToSend, BluetoothManager.swipe_uuid)
                        }
                )
                .background(Color.indigo.opacity(0.2))
        }
        .edgesIgnoringSafeArea(.all) // Make the overlay cover the entire screen
    }
}

struct ContentView: View {
    @State private var joystickPosition: CGPoint = .zero
    @State private var swipePosition: CGPoint = .zero
    @State private var xAxisValue: CGFloat = 0.0
    @State private var yAxisValue: CGFloat = 0.0
    @State private var joyStickAngle: CGFloat = 0.0
    @State private var joyStickMagnitude: CGFloat = 0.0
    @State private var joyStickAngleDegrees: CGFloat = 0.0
    @State private var swipeAngleDegrees: CGFloat = 0.0
    @State private var swipeMagnitude: CGFloat = 0.0
    @State private var abilityBars: [Bool] = Array(repeating: false, count: 10)
    @State private var timer: Timer?

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Ability bar at the bottom, centered
                HStack(spacing: 10) { // Adjust spacing as needed
                    ForEach(0..<abilityBars.count, id: \.self) { index in
                        Button(action: {
                            // Register taps in 10 different variables (abilityBars)
                            abilityBars[index].toggle()
                        }) {
                            Text("\(index + 1)")
                                .padding()
                                .background(abilityBars[index] ? Color.green : Color.gray)
                                .cornerRadius(15)
                        }
                        .frame(width: 40, height: 40) // Adjust the size as needed
                    }
                }
                .padding(.bottom, 20) // Add padding to push it slightly above the bottom
                .position(x: geometry.size.width / 2, y: geometry.size.height - 40) // Centered at the bottom

                // Joystick at the bottom left
                JoystickView(joystickPosition: $joystickPosition)
                    .frame(width: 100, height: 100) // Adjust the size as needed
                    .position(x: 170, y: geometry.size.height - 200)
                
                // SwipeGestureView
                SwipeGestureView(swipePosition: $swipePosition, swipeMagnitude: $swipeMagnitude, swipeAngleDegrees: $swipeAngleDegrees)
                    .frame(width: geometry.size.width / 2, height: geometry.size.height) // Takes up the right half of the screen
                    .position(x: geometry.size.width * 0.75, y: geometry.size.height / 2) // Centered vertically on the right side


                // Upper-right corner items
                HStack {
                    Spacer() // Push items to the right
                    VStack {
                        HStack { // Place the Image and Text horizontally
                            Image(systemName: "globe")
                                .imageScale(.small)
                                .offset(x: 0, y:20)
                                .foregroundStyle(.tint)
                                .frame(width: 30, height: 30) // Adjust the size as needed
                            Text("BattleBot App")
                                .padding(.trailing, 20) // Add padding to the right
                                .offset(x: 0, y:20)
                        }
                    }
                    Spacer() // Push items to the top
                }
                .position(x: geometry.size.width - 70, y: -12) // Adjust position as needed
            }

            Text("Joystick Angle: \(joyStickAngleDegrees), Magnitude: \(joyStickMagnitude)")
            .font(.title)
            .padding()
            
            
            Text("Swipe Angle: \(swipeAngleDegrees), Swipe Magnitude: \(swipeMagnitude)")
            .padding()
            .padding()
            .font(.title)
            .padding()
            .offset(x: -32)
        }
        .navigationBarTitle("BattleBot")
        .onAppear {
            // Start a Timer to update variables as fast as possible
            self.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
                // Update variables with joystick values
                xAxisValue = joystickPosition.x
                yAxisValue = joystickPosition.y
                // Calculate magnitude and angle
                joyStickMagnitude = sqrt(pow(xAxisValue, 2) + pow(yAxisValue, 2))
                
                // Calculate angle in radians
                joyStickAngle = atan2(yAxisValue, xAxisValue)
                
                // Convert radians to degrees (0-360, clockwise)
                joyStickAngleDegrees = (90 + joyStickAngle * 180 / .pi).truncatingRemainder(dividingBy: 360)
                
                // Send data to Bluetooth on the main thread
                DispatchQueue.main.async {
                    let dataToSend = "\(joyStickAngleDegrees),\(joyStickMagnitude)"
                    BluetoothManager.shared.sendData(dataToSend, BluetoothManager.joystick_uuid)
                }
            }
        }
        .onDisappear {
            self.timer?.invalidate()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
