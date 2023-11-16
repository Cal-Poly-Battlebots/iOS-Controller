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
    @State private var directionAngle: Angle = Angle(degrees: 0.0)
    @State private var speedMagnitude: CGFloat = 0.0

    var body: some View {
            VStack {
                Divider()
                    .padding([.leading, .trailing], 30)
                Spacer() // Pushes the rotating text to the center
                Text("Musty Bot")
                    .padding(75)
                    .font(.system(size: 34))
                    .background(Color.gray)
                    .rotationEffect(-finalFacingAngle)
                    .offset(dragOffset)
                    .gesture(
                        SimultaneousGesture(
                            RotationGesture()
                                .onChanged { angle in
                                    finalFacingAngle = currentFacingAngle - angle
                                    // Make sure the final angle is between 0 and 360 degrees
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
                                    directionAngle = dragDirection()
                                    speedMagnitude = dragMagnitude()
                                }
                                .onEnded { _ in
                                    dragOffset = .zero
                                }
                        )
                    )
                Spacer() // Pushes the angle text to the bottom
                Text("Facing Angle: \(finalFacingAngle.degrees)")
                Text("Direction Angle: \(dragDirection().degrees)")
                Text("Speed Magnitude: \(dragMagnitude())")
            }
            .navigationBarTitle("Gesture Mode")
    }

    private func dragDirection() -> Angle {
        // Calculate the angle with respect to the custom coordinate system
        var angle = atan2(dragOffset.width, -dragOffset.height)
        // Ensure the angle is positive
        if angle < 0 {
            angle += 2 * .pi
        }
        // Convert to degrees
        return Angle(radians: Double(angle))
    }


    private func dragMagnitude() -> CGFloat {
        let originalMagnitude = sqrt(pow(dragOffset.width, 2) + pow(dragOffset.height, 2))
        let maxOriginalValue = CGFloat(200) // Replace with your actual max original value

        // Nominalize the magnitude
        let normalizedMagnitude = (originalMagnitude / maxOriginalValue) * CGFloat(50)
        let cappedMagnitude = min(normalizedMagnitude, 50)

        return cappedMagnitude
    }
}

struct GestureModeView_Previews: PreviewProvider {
    static var previews: some View {
        GestureModeView()
    }
}
