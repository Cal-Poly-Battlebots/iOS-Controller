//
//  ContentView.swift
//  BattleBotJoySticks
//
//  Created by Aaron Rosen on 10/1/23.
//

import SwiftUI

struct SwipeGestureView: View {
    @Binding var joystickPosition: CGPoint
    @Binding var joyStickMagnitude: CGFloat
    @Binding var joyStickAngleDegrees: CGFloat

    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 10)
                .frame(width: 200, height: 200)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            // Update joystick position based on drag gesture
                            joystickPosition = value.location
                            // Calculate magnitude and angle
                            let xAxisValue = joystickPosition.x - 100
                            let yAxisValue = joystickPosition.y - 100
                            joyStickMagnitude = min(sqrt(pow(xAxisValue, 2) + pow(yAxisValue, 2)), 50.0)
                            joyStickAngleDegrees = (360 + atan2(xAxisValue, -yAxisValue) * 180 / .pi).truncatingRemainder(dividingBy: 360)
                            // Send data to Bluetooth
                            let dataToSend = "\(joyStickAngleDegrees),\(joyStickMagnitude)"
                            BluetoothManager.shared.sendData(dataToSend, BluetoothManager.swipe_uuid)
                        }
                        .onEnded { _ in
                            // Reset joystick position when gesture ends
                            joystickPosition = .zero
                            joyStickMagnitude = 0.0
                            joyStickAngleDegrees = 0.0
                            // Send data to Bluetooth to stop movement
                            let dataToSend = "0.0,0.0"
                            BluetoothManager.shared.sendData(dataToSend, BluetoothManager.swipe_uuid)
                        }
                )
        }
        
        Spacer()
        
        Text("Swipe Angle: \(joyStickAngleDegrees), Swipe Magnitude: \(joyStickMagnitude)")
            .font(.title)
            .padding()
    }
}

struct ContentView: View {
    @State private var joystickPosition: CGPoint = .zero
    @State private var xAxisValue: CGFloat = 0.0
    @State private var yAxisValue: CGFloat = 0.0
    @State private var joyStickAngle: CGFloat = 0.0
    @State private var joyStickMagnitude: CGFloat = 0.0
    @State private var joyStickAngleDegrees: CGFloat = 0.0
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

                // Upper-right corner items
                HStack {
                    Spacer() // Push items to the right
                    VStack {
                        HStack { // Place the Image and Text horizontally
                            Image(systemName: "globe")
                                .imageScale(.small)
                                .foregroundStyle(.tint)
                                .frame(width: 30, height: 30) // Adjust the size as needed
                            Text("BattleBot App")
                                .padding(.trailing, 20) // Add padding to the right
                        }
                    }
                    Spacer() // Push items to the top
                }
                .position(x: geometry.size.width - 70, y: -12) // Adjust position as needed
            }

            Text("Joystick Angle: \(joyStickAngleDegrees), Magnitude: \(joyStickMagnitude)")
                .font(.title)
                .padding()
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
                joyStickAngle = atan2(xAxisValue, -yAxisValue)
                
                // Convert radians to degrees (0-360, clockwise)
                joyStickAngleDegrees = (360 - joyStickAngle * 180 / .pi).truncatingRemainder(dividingBy: 360)
                
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
