//
//  ButtonView.swift
//  CP BattleBot
//
//  Created by Kieran Valino on 1/23/24.
//

import SwiftUI


struct ButtonView: View {
    @Binding var button: [Bool]

    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<button.count, id: \.self) { index in
                Button(action: {
                    button[index].toggle()
                }) {
                    // index = 0 : Weapon
                    // index = 1 : Field Orientation
                    // index = else : Power
                    Text("\(index == 0 ? "Weapon" : (index == 1 ? "Field Orientation" : "Power"))")
                        .font(.title)
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        .foregroundStyle(.black)
                        .padding(25)
                        .background(button[index] ? Color.green : Color.gray.opacity(0.4))
                        .cornerRadius(25)
                }
                // Adjust fram based on the width of the UI to fit all buttons
                .frame(width: UIScreen.main.bounds.width / 2.5, height: 40)
            }
        }
    }
}

struct ButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonView(button: .constant([false, true, true]))
    }
}
