//
//  MovementJoystick.swift
//  CP BattleBot
//
//  Created by Aaron Rosen on 10/1/23.
//  Modified by Kieran Valino

import SwiftUI


struct MovementJoystickView: View {
    // Structure for the Movement Joystick
    @Binding var joystickPosition: CGPoint

    var body: some View {
        ZStack {
            // Outline of the joystick movement
            Circle()
                .foregroundColor(Color.gray.opacity(0.1))
                .frame(width: 300, height: 300)
                .position(CGPoint(x: 0, y: 0))
            
            // Dashes representing the maximum range (North, South, East, West)
            Group {
                Dash().rotationEffect(.degrees(0)).position(.zero).offset(y: -150)
                Dash().rotationEffect(.degrees(90)).position(.zero).offset(x: 150)
                Dash().rotationEffect(.degrees(180)).position(.zero).offset(y: 150)
                Dash().rotationEffect(.degrees(-90)).position(.zero).offset(x: -150)
            }
        
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
                        let newPosition = CGPoint(x: value.location.x, y: value.location.y)
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
        // Update the Joystick position based on a new position
        let distance = sqrt(pow(newPosition.x, 2) + pow(newPosition.y, 2))
        let maxDistance: CGFloat = 150 // Maximum range

        // Limit the range to the max distance that can be pulled in the x-y direction
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
            .frame(width: 5, height: 10)
            .foregroundColor(.gray.opacity(0.4))
    }
}

struct MovementJoystickView_Previews: PreviewProvider {
    static var previews: some View {
        @State var joystickPosition: CGPoint = .zero
        return MovementJoystickView(joystickPosition: $joystickPosition)
    }
}
