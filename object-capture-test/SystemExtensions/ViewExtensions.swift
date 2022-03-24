//
//  ViewExtensions.swift
//  object-capture-test
//
//  Created by Sabrina Bea on 3/17/22.
//

import SwiftUI

extension View {
    func ocButtonStyle(_ color: Color) -> some View {
        self
            .padding()
            .background(color)
            .cornerRadius(15)
            .foregroundColor(.white)
            .padding()
    }
}
