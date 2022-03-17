//
//  ResultsView.swift
//  object-capture-test
//
//  Created by Sabrina Bea on 3/17/22.
//

import SwiftUI

struct ResultsView: View {
    var body: some View {
        ARQuickLookView(usdzFileName: "MyScene")
    }
}

struct ResultsView_Previews: PreviewProvider {
    static var previews: some View {
        ResultsView()
    }
}
