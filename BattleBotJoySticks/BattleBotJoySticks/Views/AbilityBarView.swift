//
//  AbilityBarView.swift
//  BattleBotJoySticks
//
//  Created by Kieran Valino on 1/23/24.
//

import SwiftUI

struct AbilityBarView: View {
    @Binding var abilityBar: [Bool]

    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<abilityBar.count, id: \.self) { index in
                Button(action: {
                    abilityBar[index].toggle()
                }) {
                    Text("\(index + 1)")
                        .padding()
                        .background(abilityBar[index] ? Color.green : Color.gray)
                        .cornerRadius(15)
                }
                .frame(width: 40, height: 40)
            }
        }
    }
}

struct AbilityBarView_Previews: PreviewProvider {
    static var previews: some View {
        AbilityBarView(abilityBar: .constant([false, false]))
    }
}
