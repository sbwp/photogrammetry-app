//
//  LoadingView.swift
//  object-capture-test
//
//  Created by Sabrina Bea on 3/17/22.
//

import SwiftUI
import AVKit

struct LoadingView: View {
    @Binding var images: [AVCapturePhoto]
    
    var body: some View {
        VStack {
            Text("Loading...")
                .font(.headline)
            ImageList(images: $images)
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView(images: .constant([]))
    }
}
