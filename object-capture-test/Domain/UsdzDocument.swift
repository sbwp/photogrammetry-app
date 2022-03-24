//
//  UsdzDocument.swift
//  object-capture-test
//
//  Created by Sabrina Bea on 3/18/22.
//

import SwiftUI
import UniformTypeIdentifiers

struct UsdzDocument: FileDocument {
    var data: Data

    static var readableContentTypes: [UTType] { [.usdz] }
    
    init(data: Data) {
        self.data = data
    }
    
    init(url: URL) {
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to read USDZ Document from URL")
        }
        self.data = data
    }

    init(configuration: ReadConfiguration) {
        guard let data = configuration.file.regularFileContents else {
            fatalError("Failed to read USDZ Document")
        }
        self.data = data
    }

    func fileWrapper(configuration: WriteConfiguration) -> FileWrapper {
        return .init(regularFileWithContents: data)
    }
}
