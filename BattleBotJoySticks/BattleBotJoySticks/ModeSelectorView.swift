//
//  ModeSelectorView.swift
//  BattleBotJoySticks
//
//  Created by Kieran Valino on 11/16/23.
//

import SwiftUI

struct ModeSelectorView: View {
    var body: some View {
        NavigationView{
            List {
                NavigationLink(destination: GestureModeView()) {
                    Label("Gesture Mode", systemImage: "hand.tap.fill")
                }
                NavigationLink(destination: JoystickModeView()) {
                    Label("Joystick Mode", systemImage: "l.joystick.fill")
                }
            }
            .navigationTitle("User Mode Selector")
        }
    }
}

struct ModeSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        ModeSelectorView()
    }
}
