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
    
    @Binding var selectedImages: [UIImage]
    var maxSelectionCount: Int?
    var selectionBehavior: PhotosPickerSelectionBehavior
    var matching: PHPickerFilter?
    @ViewBuilder var label: () -> Label
    
    public init(selectedImages: Binding<[UIImage]>, maxSelectionCount: Int? = 1, selectionBehavior: PhotosPickerSelectionBehavior = .default, matching: PHPickerFilter? = .images, @ViewBuilder label: @escaping () -> Label) {
        self._selectedImages = selectedImages
        self.maxSelectionCount = maxSelectionCount
        self.selectionBehavior = selectionBehavior
        self.matching = matching
        self.label = label
    }
    
    public var body: some View {
        PhotosPicker(selection: $selectedItems, maxSelectionCount: maxSelectionCount, selectionBehavior: selectionBehavior, matching: matching) {
            label()
        }
        .onChange(of: selectedItems) {
            Task {
                var selectedImages = [UIImage]()
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
