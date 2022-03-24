//
//  ObjectCaptureProject.swift
//  object-capture-test
//
//  Created by Sabrina Bea on 3/21/22.
//

import Foundation

// Probably would be better to put codable metadata as a property, but fine for demo
struct ObjectCaptureProject: Identifiable, Codable {
    var id = UUID()
    var serverId = UUID() // TODO: make server take in a UUID when creating a new project so it can use .id
    var images: [Data] = []
    
    private enum CodingKeys: String, CodingKey {
        case id
    }
}
