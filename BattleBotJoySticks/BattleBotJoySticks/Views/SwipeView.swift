//
//  SwipeView.swift
//  BattleBotJoySticks
//
//  Created by Kieran Valino on 11/16/23.
//

import SwiftUI

struct SwipeView: View {
    @State public var swipePosition: CGPoint = .zero
    @State public var swipeMagnitude: CGFloat = 0.0
    @State public var swipeAngleDegrees: CGFloat = 0.0

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
                            
                            let swipeAngle = atan2(yAxisValue, xAxisValue)
                            swipeAngleDegrees = (270 + 180 + swipeAngle * 180 / .pi).truncatingRemainder(dividingBy: 360)
                            // Send data to Bluetooth
                            let dataToSend = "\(swipeAngleDegrees),\(swipeMagnitude)\n"
                            BluetoothManager.shared.sendData(dataToSend, BluetoothManager.swipe_uuid)
                        }
                        .onEnded { _ in
                            // Reset swipe position when gesture ends
                            swipePosition = .zero
                            swipeMagnitude = 0.0
                            swipeAngleDegrees = 0.0
                            // Send data to Bluetooth to stop movement
                            let dataToSend = "0.0,0.0\n"
                            BluetoothManager.shared.sendData(dataToSend, BluetoothManager.swipe_uuid)
                        }
                )
                .background(Color.indigo.opacity(0.2))
        }
        .edgesIgnoringSafeArea(.all) // Make the overlay cover the entire screen
    }
}

struct SwipeView_Previews: PreviewProvider {
    static var previews: some View {
        SwipeView()
    }
}
