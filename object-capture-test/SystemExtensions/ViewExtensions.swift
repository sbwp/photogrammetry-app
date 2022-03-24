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
            .cornerRadius(5)
            .foregroundColor(textColor)
            .padding()
    }
    
    func blurredRow() -> some View {
        self
            .fillRow()
            .background(BlurredBackground())
    }
    
    func fillRow() -> some View {
        HStack {
            Spacer()
            self
            Spacer()
        }
    }
    
    func leftAlign() -> some View {
        HStack {
            self
            Spacer()
        }
    }
    
    func rightAlign() -> some View {
        HStack {
            Spacer()
            self
        }
    }
    
    func ceil() -> some View {
        VStack {
            self
            Spacer()
        }
    }
    
    func floor() -> some View {
        VStack {
            Spacer()
            self
        }
    }
}
