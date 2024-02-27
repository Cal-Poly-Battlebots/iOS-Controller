//
//  ButtonViewModel.swift
//  CP BattleBot
//
//  Created by Kieran Valino on 1/23/24.
//

import SwiftUI

class ButtonViewModel: ObservableObject {
    @Published var inputButtons: [Bool] = Array([false, true, true]) // 011
}

