//
//  CustomButtonView.swift
//  AsynchronousProgramming
//
//  Created by Phil Kirby on 2/27/25.
//

import Foundation
import SwiftUI

enum ButtonColor {
    case blue
    case green
    case red
    
    var description: Color {
        switch(self) {
        case .blue: return .blue.opacity(0.8)
        case .green: return .green.opacity(0.8)
        case .red: return .red.opacity(0.8)
        }
    }
}

struct CustomButtonView: View {
    var text: String = "CustomButtonView"
    let color: ButtonColor
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(text)
                .padding()
                //This sets the text color
                .foregroundColor(.white)
                //This sets the background shape and color
                .background(
                    color.description,
                    in: RoundedRectangle(
                        cornerRadius: 10,
                        style: .continuous
                    )
                )
        }
    }
}
