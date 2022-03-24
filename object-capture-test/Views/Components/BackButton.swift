//
//  BackButton.swift
//  object-capture-test
//
//  Created by Sabrina Bea on 3/23/22.
//

import SwiftUI

struct BackButton: View {
    var title = "Back"
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "chevron.left")
                Text(title)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
