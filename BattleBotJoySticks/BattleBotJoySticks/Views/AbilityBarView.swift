//
//  AbilityBarView.swift
//  BattleBotJoySticks
//
//  Created by Kieran Valino on 1/23/24.
//

import SwiftUI

struct AbilityBarView: View {
    @Binding var abilityBars: [Bool]

    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<abilityBars.count, id: \.self) { index in
                Button(action: {
                    abilityBars[index].toggle()
                }) {
                    Text("\(index + 1)")
                        .padding()
                        .background(abilityBars[index] ? Color.green : Color.gray)
                        .cornerRadius(15)
                }
                .frame(width: 40, height: 40)
            }
        }
    }
}

struct AbilityBarView_Previews: PreviewProvider {
    static var previews: some View {
        AbilityBarView(abilityBars: .constant([false, false, false, false, false, false, false, false, false, false]))
    }
}
