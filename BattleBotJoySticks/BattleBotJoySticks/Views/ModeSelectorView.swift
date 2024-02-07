//
//  ModeSelectorView.swift
//  BattleBotJoySticks
//
//  Created by Kieran Valino on 11/16/23.
//

import SwiftUI

struct ModeSelectorView: View {
    let abilityBarViewModel = AbilityBarViewModel()
    let navigationBarViewModel = NavigationBarViewModel()
    
    var body: some View {
        NavigationView{
            List {
                NavigationLink(destination: GestureModeView(abilityBarViewModel: abilityBarViewModel, navigationBarViewModel: navigationBarViewModel)) {
                    Label("Gesture Mode", systemImage: "hand.tap.fill")
                }
                NavigationLink(destination: JoystickModeView(abilityBarViewModel: abilityBarViewModel, navigationBarViewModel: navigationBarViewModel)) {
                    Label("Joystick Mode", systemImage: "l.joystick.fill")
                }
                NavigationLink(destination: HybridModeView(abilityBarViewModel: abilityBarViewModel, navigationBarViewModel: navigationBarViewModel)) {
                    Label("Hybrid Mode", systemImage: "rectangle.and.hand.point.up.left.fill")
                }
            }
            .navigationTitle("Mode Selector")
        }
    }
}

struct ModeSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        ModeSelectorView()
    }
}
