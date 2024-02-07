//
//  HybridModeView.swift
//  BattleBotJoySticks
//
//  Created by Kieran Valino on 11/16/23.
//

import SwiftUI

struct HybridModeView: View {
    @State private var currentFacingAngle = Angle(degrees: 0.0)
    @State private var finalFacingAngle = Angle(degrees: 0)
    @State private var timer: Timer?
    
    @ObservedObject var abilityBarViewModel: AbilityBarViewModel
    @ObservedObject var navigationBarViewModel: NavigationBarViewModel
    
    @State private var joystickPosition: CGPoint = .zero
    
    let safeAreaBorder: CGFloat = 20.0
    
    var body: some View {
        NavigationStack {
            VStack{
                HStack{
                    VStack(alignment: .leading){
                        HStack{
                            VStack(alignment: .leading) {
                                Text("Facing Angle: \(String(format: "%.2f", finalFacingAngle.degrees))")
                                    .font(.title2)
                                Text("Joystick Angle: \(String(format: "%.2f", joystickAngle().degrees))")
                                    .font(.title2)
                                Text("Joystick Magnitude: \(String(format: "%.2f", joystickMagnitude()))")
                                    .font(.title2)
                            }
                            Spacer()
                        }
                        Spacer()
                        Spacer()
                        Spacer()
                        JoystickView(joystickPosition: $joystickPosition, joystickType: .left)
                        .frame(width: 100, height: 100)
                        .padding([.leading, .trailing], safeAreaBorder + 100)
                        Spacer()
                    }
                    .padding([.leading, .trailing], safeAreaBorder)
                    
                    // Swipe Zone
                    RoundedRectangle(cornerRadius: 10.0)
                        .fill(Color.indigo.opacity(0.2))
                        .padding([.leading, .trailing], safeAreaBorder)
                        .overlay(
                            VStack{
                                HStack {
                                    Spacer()
                                    // Visual Representation (top right corner) of what is happening to the Robot
                                    RoundedRectangle(cornerRadius: 10.0)
                                        .fill(Color.gray)
                                        .frame(width: 100, height: 70)
                                        .overlay(
                                            Text("Claymore")
                                                .foregroundColor(.white)
                                                .font(.system(size: 14))
                                        )
                                        .padding([.leading, .trailing], safeAreaBorder + 30)
                                        .padding([.top, .bottom], safeAreaBorder+20)
                                        // Add rotation from RotationGesture in Swipe Zone
                                        .rotationEffect(finalFacingAngle)
                                }
                                Spacer()
                            }
                        )
                        .gesture(
                            RotationGesture()
                                .onChanged { angle in
                                    // Add the currentFacingAngle to the finalFacingAngle to accumulate rotations
                                    finalFacingAngle = currentFacingAngle + angle
                                    // Make sure the angle is between 0 and 360 degrees
                                    if finalFacingAngle.degrees < 0 {
                                        finalFacingAngle = .degrees(360 + finalFacingAngle.degrees)
                                    } else if finalFacingAngle.degrees >= 360 {
                                        finalFacingAngle = .degrees(finalFacingAngle.degrees - 360)
                                    }
                                }
                                .onEnded { angle in
                                    currentFacingAngle = finalFacingAngle
                                }
                        )
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
            // Use onAppear to start sending data when the view appears
            .onAppear {
                startSendingBluetoothData()
            }
            // Use onDisappear to stop sending data when the view disappears
            .onDisappear {
                stopSendingBluetoothData()
            }
            
        }
        .navigationBarTitle("Hybrid Mode")
        
    }
    
    // Start sending Bluetooth data
    private func startSendingBluetoothData() {
        // Start a timer to regularly send data over Bluetooth
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            // Convert angles to degrees and send over Bluetooth
            let facingAngle = finalFacingAngle.degrees
            let joyAngle = joystickAngle().degrees
            let joyMag = joystickMagnitude()
            
            // Format the data as a string (you can adjust this based on your Bluetooth communication protocol)
            DispatchQueue.main.async {
                let dataToSend1 = "\(joyAngle),\(joyMag)"
                let dataToSend2 = "\(facingAngle), 50"
                
                BluetoothManager.shared.sendData(dataToSend1, BluetoothManager.joystick_uuid.uuidString)
                BluetoothManager.shared.sendData(dataToSend2, BluetoothManager.rotation_uuid.uuidString)
                
            }
        }
    }
    
    // Stop sending Bluetooth data
    private func stopSendingBluetoothData() {
        // Invalidate the timer when the view disappears
        timer?.invalidate()
    }
    
    private func joystickAngle() -> Angle {
        // Calculate the angle based on the joystick's position
        
        var angle = atan2(joystickPosition.y, joystickPosition.x)
        
        angle += .pi / 2
        
        // Normalize the angle to be between 0 and 2*pi
        if angle < 0 {
            angle += 2 * .pi
        }
        if joystickMagnitude() < 2 {
            angle = 0
        }
        return Angle(radians: Double(angle))
    }
    
    private func joystickMagnitude() -> CGFloat {
        return sqrt(pow(joystickPosition.x, 2) + pow(joystickPosition.y, 2)) / 3
    }
    
}
    
struct HybridModeView_Previews: PreviewProvider {
    static var previews: some View {
        let abilityBarViewModel = AbilityBarViewModel()
        let navigationBarViewModel = NavigationBarViewModel()
        return HybridModeView(abilityBarViewModel: abilityBarViewModel, navigationBarViewModel: navigationBarViewModel)
    }
}
