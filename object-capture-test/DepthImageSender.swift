//
//  DepthImageSender.swift
//  object-capture-test
//
//  Created by Sabrina Bea on 3/17/22.
//

import Foundation
import AVFoundation

public func sendDepthImages(_ images: [AVCapturePhoto]) {
    var urlComps = URLComponents()
    urlComps.scheme = "http"
    urlComps.host = "192.168.4.44"
    urlComps.port = 8080
    urlComps.path = "/photogrammetry"
//    urlComps.queryItems = [
//        URLQueryItem(name: "url", value: url),
//    ]
    
    if let url = urlComps.url {
        print(url.absoluteString)
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let response = response as? HTTPURLResponse, let data = data, (200...299).contains(response.statusCode) else {
                return
            }
        }
        
        task.resume()
    }
}
