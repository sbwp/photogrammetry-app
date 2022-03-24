//
//  ResultsView.swift
//  object-capture-test
//
//  Created by Sabrina Bea on 3/17/22.
//

import SwiftUI

struct ResultsView: View {
    @State var showExport = false
    @Binding var displayMode: DisplayMode
    var service: ObjectCaptureService
    
    var body: some View {
        VStack {
            HStack {
                Button("Back") {
                    displayMode = .preview
                }
                .padding()
                Spacer()
                Button("Save") {
                    showExport = true
                }
                .padding()
            }
            ARQuickLookView(usdzFileUrl: service.resultUrl)
        }
        .fileExporter(isPresented: $showExport, document: UsdzDocument(url: service.resultUrl), contentType: .usdz, defaultFilename: "MyScene.usdz") { _ in }
    }
}

struct ResultsView_Previews: PreviewProvider {
    static var previews: some View {
        ResultsView(displayMode: .constant(.results), service: ObjectCaptureService())
    }
}
