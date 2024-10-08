//
//  ImageList.swift
//  object-capture-test
//
//  Created by Sabrina Bea on 3/17/22.
//

import SwiftUI
import AVKit

struct ImageList: View {
    @EnvironmentObject var document: ObjectCaptureProjectFile
    @Environment(\.undoManager) var undo
    let editable: Bool
    
    var body: some View {
        List {
            ForEach(document.project.images, id: \.self) { image in
                if let uiImage = UIImage(data: image) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .deleteDisabled(!editable)
                } else {
                    Text("Corrupt image")
                        .deleteDisabled(!editable)
                }
            }
            .onDelete { offsets in
                document.delete(offsets: offsets, undo: undo)
            }
            .onMove { offsets, toOffset in
                document.moveItemsAt(offsets: offsets, toOffset: toOffset, undo: undo)
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
        
    }
}

struct ImageList_Previews: PreviewProvider {
    static var previews: some View {
        return ImageList(editable: true)
            .preferredColorScheme(.dark)
            .environmentObject(ObjectCaptureProjectFile.preview)
    }
}
