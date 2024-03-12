//
//  ButtonViewModel.swift
//  CP BattleBot


import SwiftUI

class ButtonViewModel: ObservableObject {
    // Initial declaration of the Button View
    @Published var inputButtons: [Bool] = Array([false, true, true]) // 011
}

