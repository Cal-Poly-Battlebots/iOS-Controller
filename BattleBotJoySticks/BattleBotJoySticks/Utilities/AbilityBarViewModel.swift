//
//  AbilityBarViewModel.swift
//  BattleBotJoySticks
//
//  Created by Kieran Valino on 1/23/24.
//

import SwiftUI

class AbilityBarsViewModel: ObservableObject {
    @Published var abilityBars: [Bool] = Array(repeating: false, count: 10)
}

