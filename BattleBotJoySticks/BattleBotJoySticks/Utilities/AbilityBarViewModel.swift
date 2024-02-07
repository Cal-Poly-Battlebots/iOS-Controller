//
//  AbilityBarViewModel.swift
//  BattleBotJoySticks
//
//  Created by Kieran Valino on 1/23/24.
//

import SwiftUI

class AbilityBarViewModel: ObservableObject {
    @Published var abilityBar: [Bool] = Array(repeating: false, count: 5)
}

class NavigationBarViewModel: ObservableObject {
    @Published var navigationBar: [Bool] = Array(repeating: false, count: 3)
}

