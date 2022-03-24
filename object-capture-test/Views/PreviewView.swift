//
//  PreviewView.swift
//  object-capture-test
//
//  Created by Sabrina Bea on 3/17/22.
//

import SwiftUI
import AVKit

struct PreviewView: View {
    @EnvironmentObject var document: ObjectCaptureProjectFile
    @Binding var displayMode: DisplayMode
    var service: ObjectCaptureService
    
    var body: some View {
        ZStack {
            ImageList(editable: true)
                .padding(.vertical, 50)
            
            VStack {
                HStack {
                    Text("\(document.project.images.count) Photo\(document.project.images.count == 1 ? "" : "s")")
                    Spacer()
                    Button(action: { displayMode = .capture }) {
                        ZStack {
                            Image(systemName: "camera")
                                .foregroundColor(.green)
                                .font(.system(size: 30))
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.green)
                                .background(Color.black)
                                .cornerRadius(500)
                                .padding(.leading, -25)
                                .padding(.bottom, -35)
                                .padding(.top, 8)
                        }
                    }
                }
                .padding()
                .background(BlurredBackground())
                Spacer()
            }
            
            VStack {
                Spacer()
                Button(action: {
                    service.sendDepthImages(document.project.images)
                    displayMode = .loading
                }) {
                    Label("Upload", systemImage: "tray.and.arrow.up.fill")
                        .fillRow()
                }
                .ocButtonStyle(.white, textColor: .accentColor)
                .font(.system(size: 24))
                .blurredRow()
            }
        }
    }
}

struct PreviewView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewView(displayMode: .constant(.preview), service: ObjectCaptureService())
            .preferredColorScheme(.dark)
            .environmentObject(ObjectCaptureProjectFile.preview)
    }
}
