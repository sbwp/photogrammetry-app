//
//  ObjectCaptureProjectDocument.swift
//  object-capture-test
//
//  Created by Sabrina Bea on 3/21/22.
//

import SwiftUI
import UniformTypeIdentifiers
import AVFoundation

class ObjectCaptureProjectFile: ReferenceFileDocument {
    static var readableContentTypes: [UTType] { [.objectCaptureProjectDocument] }
    let imagesDirName = "images"
    let projectFileName = "project-info"
    @Published var project: ObjectCaptureProject
    
    init() {
        project = ObjectCaptureProject()
    }
    
    required init(configuration: ReadConfiguration) throws {
        guard let projectData = configuration.file.fileWrappers?[projectFileName]?.regularFileContents,
              let imagesDir = configuration.file.fileWrappers?[imagesDirName]?.fileWrappers
        else {
            fatalError("Failed to read project file")
        }
        self.project = try JSONDecoder().decode(ObjectCaptureProject.self, from: projectData)
        
        for (_, fileWrapper) in imagesDir {
            guard let data = fileWrapper.regularFileContents else {
                fatalError("Failed to read project images")
            }
            project.images.append(data)
        }
    }
    
    func snapshot(contentType: UTType) -> ObjectCaptureProject {
        project
    }
    
    func fileWrapper(snapshot: ObjectCaptureProject, configuration: WriteConfiguration) throws -> FileWrapper {
        print("Saving")
        let imagesDir = FileWrapper(directoryWithFileWrappers: [:])
        imagesDir.filename = imagesDirName
        imagesDir.preferredFilename = imagesDirName
        
        for (index, data) in snapshot.images.enumerated() {
            let imageFile = FileWrapper(regularFileWithContents: data)
            imageFile.filename = "image_\(index).heif"
            imageFile.preferredFilename = "image_\(index).heif"
            
            imagesDir.addFileWrapper(imageFile)
        }
        
        return FileWrapper(directoryWithFileWrappers: [
            imagesDirName: imagesDir,
            projectFileName: FileWrapper(regularFileWithContents: try JSONEncoder().encode(snapshot))
        ])
    }
}

// Image CRUD
extension ObjectCaptureProjectFile {
    func addImage(image: Data, undo: UndoManager? = nil) {
        let index = project.images.count
        project.images.append(image)
        
        undo?.registerUndo(withTarget: self) { doc in
            doc.deleteImage(index: index, undo: undo)
        }
    }
    
    func deleteImage(index: Int, undo: UndoManager? = nil) {
        let oldImages = project.images
        withAnimation {
            _ = project.images.remove(at: index)
        }
        
        undo?.registerUndo(withTarget: self) { doc in
            doc.replaceImages(with: oldImages, undo: undo)
        }
    }
    
    func replaceImages(with images: [Data], undo: UndoManager? = nil) {
        let oldImages = project.images
        withAnimation {
            project.images = images
        }
        
        undo?.registerUndo(withTarget: self) { doc in
            doc.replaceImages(with: oldImages, undo: undo)
        }
    }
    
    func delete(offsets: IndexSet, undo: UndoManager? = nil) {
        let oldImages = project.images
        withAnimation {
            project.images.remove(atOffsets: offsets)
        }
        
        undo?.registerUndo(withTarget: self) { doc in
            doc.replaceImages(with: oldImages, undo: undo)
        }
    }
    
    func moveItemsAt(offsets: IndexSet, toOffset: Int, undo: UndoManager? = nil) {
        let oldImages = project.images
        withAnimation {
            project.images.move(fromOffsets: offsets, toOffset: toOffset)
        }
        
        undo?.registerUndo(withTarget: self) { doc in
            doc.replaceImages(with: oldImages, undo: undo)
        }
        
    }
}
