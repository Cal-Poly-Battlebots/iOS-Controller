//
//  BattleBotJoySticksApp.swift
//  BattleBotJoySticks
//
//  Created by Aaron Rosen on 10/1/23.
//

import SwiftUI

struct JoystickView: View {
    @Binding var joystickPosition: CGPoint

    var body: some View {
        ZStack {
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
                .gesture(
                    DragGesture()
                    .onChanged { value in
                        // Update joystick position based on drag
                        let newPosition = value.location
                        let distance = sqrt(pow(newPosition.x, 2) + pow(newPosition.y, 2))
                        let maxDistance: CGFloat = 50 // Maximum range
                        
                        if distance <= maxDistance {
                            joystickPosition = newPosition
                        } else {
                            // Limit joystick movement within the maximum range
                            let angle = atan2(newPosition.y, newPosition.x)
                            joystickPosition = CGPoint(x: maxDistance * cos(angle), y: maxDistance * sin(angle))
                        }
                    }
                    .onEnded { _ in
                        // Reset the joystick position when dragging ends
                        joystickPosition = .zero
                    }
            )
            
            Group {
                // Dashes representing the maximum range (North, South, East, West)
                Dash()
                    .rotationEffect(.degrees(0))
                    .position(.zero)
                    .offset(y: -80)
                
                Dash()
                    .rotationEffect(.degrees(90))
                    .position(.zero)
                    .offset(x: 80)
                
                Dash()
                    .rotationEffect(.degrees(180))
                    .position(.zero)
                    .offset(y: 80)
                
                Dash()
                    .rotationEffect(.degrees(-90))
                    .position(.zero)
                    .offset(x: -80)
            }
        }
        .frame(width: 30, height: 30)
    }
}

struct Dash: View {
    var body: some View {
        Rectangle()
            .frame(width: 2, height: 10)
            .foregroundColor(.gray.opacity(0.4))
    }
}

@main
struct BattleBotJoySticksApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
