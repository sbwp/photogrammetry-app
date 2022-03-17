//
//  ImageList.swift
//  object-capture-test
//
//  Created by Sabrina Bea on 3/17/22.
//

import SwiftUI
import AVKit

struct ImageList: View {
    @Binding var images: [AVCapturePhoto]
    
    var body: some View {
        List(images, id: \.self) { image in
            Image(uiImage: UIImage(cgImage: image.cgImageRepresentation()!, scale: 1, orientation: .right))
                .resizable()
                .frame(width: 240, height: 300)
        }
    }
}

struct ImageList_Previews: PreviewProvider {
    static var previews: some View {
        ImageList(images: .constant([]))
    }
}
