//
//  RotationJoystick.swift
//  CP BattleBot
//
//  Created by Aaron Rosen on 10/1/23.
//  Modified by Kieran Valino

import SwiftUI

struct RotationJoystickView: View {
    @Binding var joystickPosition: CGPoint

    var body: some View {
        ZStack {
            // Outline of the joystick movement
            RoundedRectangle(cornerRadius: 100.0)
                .foregroundColor(Color.gray.opacity(0.1))
                .frame(width: 400, height: 100)
                .position(CGPoint(x: 0, y: 0))
            
            // Dashes representing the maximum range (East, West)
            Group {
                Dash().rotationEffect(.degrees(90)).position(.zero).offset(x: 150)
                Dash().rotationEffect(.degrees(-90)).position(.zero).offset(x: -150)
            }
            // Create the joystick circle
            Circle()
                .frame(width: 100, height: 100)
                .foregroundColor(.gray.opacity(0.4))
                .position(joystickPosition)
                .overlay(
                    Circle()
                        .stroke(Color.gray.opacity(0.4), lineWidth: 10)
                        .frame(width: 112, height: 112)
                        .position(.zero)
                )
                // What happens when circle is dragged
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            // Calculate new position only on the x-axis
                            let newPosition = CGPoint(x: value.location.x, y: joystickPosition.y)
                            updateJoystickPosition(newPosition)
                        }
                        // When joystick is released
                        .onEnded { _ in
                            // Reset the joystick position when dragging ends
                            joystickPosition = .zero
                        }
                )

        }
        .frame(width: 30, height: 30)
    }

    private func updateJoystickPosition(_ newPosition: CGPoint) {
        let distance = abs(newPosition.x)
        let maxDistance: CGFloat = 150 // Maximum range

        if distance <= maxDistance {
            joystickPosition = newPosition
        } else {
            let angle = atan2(newPosition.y, newPosition.x)
            joystickPosition = CGPoint(x: maxDistance * cos(angle), y: maxDistance * sin(angle))
        }
    }
}

struct RotationJoystickView_Previews: PreviewProvider {
    static var previews: some View {
        @State var joystickPosition: CGPoint = .zero
        return RotationJoystickView(joystickPosition: $joystickPosition)
    }
}
