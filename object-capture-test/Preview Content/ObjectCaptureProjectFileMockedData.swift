//
//  ObjectCaptureProjectFilePreview.swift
//  object-capture-test
//
//  Created by Sabrina Bea on 3/23/22.
//

import UIKit

extension ObjectCaptureProjectFile {
    static var preview: ObjectCaptureProjectFile {
        let file = ObjectCaptureProjectFile()
        
        if let data = UIImage(named: "SampleImage")?.pngData() {
            file.addImage(image: data)
            file.addImage(image: data)
            file.addImage(image: data)
            file.addImage(image: data)
            file.addImage(image: data)
            file.addImage(image: data)
            file.addImage(image: data)
        } else {
            file.addImage(image: Data())
        }
        
        return file
    }
}
