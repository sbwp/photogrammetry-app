//
//  Blur.swift
//  object-capture-test
//
//  Published for free use by Richard Mullinix - https://medium.com/@edwurtle/blur-effect-inside-swiftui-a2e12e61e750
//

import SwiftUI

struct Blur: UIViewRepresentable {
    var style: UIBlurEffect.Style = .systemMaterial

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}
