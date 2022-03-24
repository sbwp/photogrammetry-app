//
//  BlurredBackground.swift
//  object-capture-test
//
//  Created by Sabrina Bea on 3/23/22.
//

import SwiftUI

struct BlurredBackground: View {
    var body: some View {
        Blur(style: .systemUltraThinMaterial)
            .ignoresSafeArea()
            .shadow(color: .gray, radius: 0.6, x: 0, y: 0)
    }
}
