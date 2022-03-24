//
//  ViewExtensions.swift
//  object-capture-test
//
//  Created by Sabrina Bea on 3/17/22.
//

import SwiftUI

extension View {
    func ocButtonStyle(_ color: Color, textColor: Color = .white) -> some View {
        self
            .padding(12)
            .background(color)
            .cornerRadius(15)
            .foregroundColor(textColor)
            .padding()
    }
}
