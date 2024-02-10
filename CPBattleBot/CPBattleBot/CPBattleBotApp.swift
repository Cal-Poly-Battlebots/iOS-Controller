//
//  CPBattleBotApp.swift
//  CP BattleBot
//
//  Created by Aaron Rosen and Kieran Valino
//  Designed for Cal Poly Capstone and client Kirk Branner
//

import SwiftUI

@main
struct CPBattleBotApp: App 
{
    let abilityBarViewModel = AbilityBarViewModel()
    let navigationBarViewModel = NavigationBarViewModel()
    
    var body: some Scene {
        WindowGroup {
            JoystickModeView(abilityBarViewModel: abilityBarViewModel, navigationBarViewModel: navigationBarViewModel)
        }
    }
}
