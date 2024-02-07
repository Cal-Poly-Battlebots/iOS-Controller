//
//  GestureModeView.swift
//  BattleBotJoySticks
//
//  Created by Kieran Valino on 11/16/23.
//

import SwiftUI

struct GestureModeView: View {
    @State private var currentFacingAngle = Angle(degrees: 0.0)
    @State private var finalFacingAngle = Angle(degrees: 0)
    @State private var dragOffset: CGSize = .zero
    @State private var timer: Timer?
    
    @ObservedObject var abilityBarViewModel: AbilityBarViewModel
    @ObservedObject var navigationBarViewModel: NavigationBarViewModel
    
    
    
    let safeAreaBorder: CGFloat = 50.0
    
    var body: some View {
        NavigationStack {
            VStack{
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
                                    .padding([.leading, .trailing], safeAreaBorder + 50)//safeAreaBorder + 55)
                                    .padding([.top, .bottom], safeAreaBorder)
                                    //.padding([.top,.bottom], safeAreaBorder + 50)
                                    // Add rotation from RotationGesture in Swipe Zone
                                    .rotationEffect(finalFacingAngle)
                                    // Add movement from DragGesture in Swipe Zone
                                    .offset(scaledDragOffset())
                            }
                            Spacer()
                            HStack {
                                // Measurements for User (bottom left corner)
                                VStack(alignment: .leading) {
                                    Text("Facing Angle: \(String(format: "%.2f", finalFacingAngle.degrees))")
                                    Text("Drag Angle: \(String(format: "%.2f", dragDirection().degrees))")
                                    Text("Drag Magnitude: \(String(format: "%.2f", dragMagnitude()))")
                                }
                                .padding(.leading, safeAreaBorder + 10)
                                .padding(.bottom, 10)
                                Spacer()
                            }
                            
                        }
                    )
                    .gesture(
                        SimultaneousGesture(
                            RotationGesture()
                                .onChanged { angle in
                                    // Add the currentFacingAngle to the finalFacingAngle to accumulate rotations
                                    // Don not do something like 'finalFacing += angle' or else Visual Representation will spin like crazy for tiny angle changes
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
                                },
                            DragGesture()
                                .onChanged { value in
                                    dragOffset = value.translation
                                    self.timer?.invalidate()

                                    // Check if dragMagnitude is zero and reset dragAngle
                                    if dragMagnitude() == 0 {
                                        currentFacingAngle = .degrees(0)
                                    }
                                }
                                .onEnded { _ in
                                    // Start the timer only if dragMagnitude is not zero
                                    if dragMagnitude() != 0 {
                                        self.startTimer()
                                    }
                                }
                        )
                        // Add TapGesture that will reset dragOffset to zero
                        .simultaneously(with: TapGesture().onEnded {
                            dragOffset = .zero
                        })
                    )
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
        .navigationBarTitle("Gesture Mode")
        
    }
    
    private func startTimer() {
        // Start a timer to gradually set dragOffset to zero
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.025, repeats: true) { _ in
            let damping: CGFloat = 0.975 // Adjust damping as needed
            self.dragOffset.width *= damping
            self.dragOffset.height *= damping
            if abs(self.dragOffset.width) < 0.1 && abs(self.dragOffset.height) < 0.1 {
                // Stop the timer when dragOffset is close to zero
                self.timer?.invalidate()
                self.dragOffset = .zero
            }
        }
    }
    
    // Start sending Bluetooth data
    private func startSendingBluetoothData() {
        // Start a timer to regularly send data over Bluetooth
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            // Convert angles to degrees and send over Bluetooth
            let facingAngle = finalFacingAngle.degrees
            let dragAngle = dragDirection().degrees
            let dragMag = dragMagnitude()
            
            DispatchQueue.main.async {
                let dataToSend1 = "\(dragAngle),\(dragMag)"
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
    
    private func scaledDragOffset() -> CGSize {
        // Define the maximum movement for both horizontal and vertical directions
        let maxHorizontalMovement: CGFloat = 50.0
        let maxVerticalMovement: CGFloat = 50.0

        // Calculate the scaling factors based on the normalized values of dragOffset
        let normalizedHorizontal = dragOffset.width / UIScreen.main.bounds.width
        let normalizedVertical = dragOffset.height / UIScreen.main.bounds.height

        // Apply scaling factors to limit the movement
        let scaledHorizontal = normalizedHorizontal * maxHorizontalMovement
        let scaledVertical = normalizedVertical * maxVerticalMovement

        // Rotate the movement based on the facing angle
        let rotatedHorizontal = scaledHorizontal * CGFloat(cos(Double(finalFacingAngle.radians))) - scaledVertical * CGFloat(sin(Double(finalFacingAngle.radians)))
        let rotatedVertical = scaledHorizontal * CGFloat(sin(Double(finalFacingAngle.radians))) + scaledVertical * CGFloat(cos(Double(finalFacingAngle.radians)))

        // Return the rotated CGSize
        //return CGSize(width: scaledHorizontal, height: scaledVertical)
        return CGSize(width: rotatedHorizontal, height: rotatedVertical)
    }

    
    private func dragMagnitude() -> CGFloat {
        // Calculate the components of drag offset along the horizontal and vertical directions
        let horizontalComponent = dragOffset.width
        let verticalComponent = dragOffset.height
        
        // Normalize the components based on the width and height of the Swipe Zone
        let normalizedHorizontal = horizontalComponent / (UIScreen.main.bounds.width / 2)//600 // Replace 1000 with the actual width of the Swipe Zone
        let normalizedVertical = verticalComponent / (UIScreen.main.bounds.height / 2)//400 // Replace 600 with the actual height of the Swipe Zone
        
        // Calculate the magnitude of the normalized vector
        let normalizedMagnitude = sqrt(pow(normalizedHorizontal, 2) + pow(normalizedVertical, 2))
        
        // Scale the normalized magnitude to the desired range (e.g., 0 to 50)
        let scaledMagnitude = normalizedMagnitude * 50
        
        // Clamp the scaledMagnitude to ensure it does not exceed the maximum value (50)
        let clampedMagnitude = min(scaledMagnitude, 50)
        
        if clampedMagnitude > 2.0 {
            return clampedMagnitude
        } else {
            // If less than 2.0, round to 0.0
            return 0.0
        }
    }
    
    private func dragDirection() -> Angle {
        // Calculate the angle with respect to the custom coordinate system
        var angle = atan2(dragOffset.width, -dragOffset.height)
//        // Ensure the angle is positive
//        if angle < 0 {
//            angle += 2 * .pi
//        }
        
        // Subtract the facingAngle from the calculated angle
        angle -= CGFloat(finalFacingAngle.radians)
        
        // Normalize the angle to be between 0 and 2*pi
        if angle < 0 {
            angle += 2 * .pi
        }
        if dragMagnitude() < 2 {
            angle = 0
        }
        return Angle(radians: Double(angle))
    }
    
}
    
struct GestureModeView_Previews: PreviewProvider {
    static var previews: some View {
        let abilityBarViewModel = AbilityBarViewModel()
        let navigationBarViewModel = NavigationBarViewModel()
        return GestureModeView(abilityBarViewModel: abilityBarViewModel, navigationBarViewModel: navigationBarViewModel)
    }
}
