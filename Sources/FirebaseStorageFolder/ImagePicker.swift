//
//  ImagePicker.swift
//  FirebaseStorageFolder
//
//  Created by Alex Nagy on 21.02.2025.
//

import SwiftUI
import PhotosUI

public struct ImagePicker<Label: View>: View {
    
    @State private var selectedItems = [PhotosPickerItem]()
    @State private var selectedImages = [UIImage]()
    
    var maxSelectionCount: Int?
    var selectionBehavior: PhotosPickerSelectionBehavior
    var matching: PHPickerFilter?
    @ViewBuilder var label: @Sendable ([UIImage]) -> Label
    
    public init(maxSelectionCount: Int? = nil, selectionBehavior: PhotosPickerSelectionBehavior = .default, matching: PHPickerFilter? = .images, @ViewBuilder label: @Sendable @escaping ([UIImage]) -> Label) {
        self.maxSelectionCount = maxSelectionCount
        self.selectionBehavior = selectionBehavior
        self.matching = matching
        self.label = label
    }
    
    public var body: some View {
        PhotosPicker(selection: $selectedItems, maxSelectionCount: 1, selectionBehavior: selectionBehavior, matching: matching) { [selectedImages] in
            label(selectedImages)
        }
        .onChange(of: selectedItems) {
            Task {
                var selectedImages = [Image]()
                for item in selectedItems {
                    if let data = try? await item.loadTransferable(type: Data.self), let uiImage = UIImage(data: data) {
                        selectedImages.append(uiImage)
                    }
                }
                self.selectedImages = selectedImages
            }
        }
    }
}
