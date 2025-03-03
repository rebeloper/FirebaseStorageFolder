//
//  FirebaseStorageFolder.swift
//
//
//  Created by Alex Nagy on 18.02.2025.
//

import SwiftUI
import FirebaseStorage

@Observable
public class FirebaseStorageFolder {
    
    let storage: Storage
    let path: String
    
    public init(storage: Storage = Storage.storage(), path: String) {
        self.storage = storage
        self.path = path
    }
    
    public enum ImageCompressionType {
        case jpeg(compressionQuality: CGFloat)
        case png
    }
    
    public func upload(datas: [Data]) async throws -> [String] {
        let reference = storage.reference().child(path)
        return try await withThrowingTaskGroup(of: String.self) { group in
            var urlStrings = [String]()
            for (index, data) in datas.enumerated() {
                group.addTask(priority: .background) {
                    let _ = try await reference.child("\(index)").putDataAsync(data)
                    return try await reference.child("\(index)").downloadURL().absoluteString
                }
            }
            for try await uploadedDataString in group {
                urlStrings.append(uploadedDataString)
            }
            return urlStrings
        }
    }
    
    public func upload(data: Data) async throws -> String {
        try await upload(datas: [data]).first!
    }
    
    public func upload(image: UIImage, compressionType: ImageCompressionType = .jpeg(compressionQuality: 0.8)) async throws -> String? {
        switch compressionType {
            case .jpeg(compressionQuality: let compressionQuality):
            guard let data = image.jpegData(compressionQuality: compressionQuality) else { return nil }
            return try await upload(data: data)
        case .png:
            guard let data = image.pngData() else { return nil }
            return try await upload(data: data)
        }
    }
    
    public func upload(images: [UIImage], compressionType: ImageCompressionType = .jpeg(compressionQuality: 0.8)) async throws -> [String] {
        var imagesData: [Data] = []
        for image in images {
            switch compressionType {
            case .jpeg(compressionQuality: let compressionQuality):
                if let data = image.jpegData(compressionQuality: compressionQuality) {
                    imagesData.append(data)
                }
            case .png:
                if let data = image.pngData() {
                    imagesData.append(data)
                }
            }
        }
        return try await upload(datas: imagesData)
    }
    
    public func delete(at url: String) async throws {
        try await storage.reference(forURL: url).delete()
    }
    
    public func handleImageChange(_ newImage: UIImage, compressionType: ImageCompressionType = .jpeg(compressionQuality: 0.8), oldImageUrl: String) async throws -> String? {
        guard oldImageUrl.contains("https") else {
            return try await upload(image: newImage, compressionType: compressionType)
        }
        try await delete(at: oldImageUrl)
        return try await upload(image: newImage, compressionType: compressionType)
    }
    
    public func handleDataChange(_ newData: Data, oldDataUrl: String) async throws -> String? {
        guard oldDataUrl.contains("https") else {
            return try await upload(data: newData)
        }
        try await delete(at: oldDataUrl)
        return try await upload(data: newData)
    }
}

