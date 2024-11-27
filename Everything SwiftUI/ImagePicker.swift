import SwiftUI
import PhotosUI

/// iOS 16+
// MARK: Custom Image Picker with Drag & Drop
struct ImagePicker: View {
    var title, subTitle, systemImage: String
    var tint: Color
    var onImageChange: (UIImage) -> ()
    
    @State private var showImagePicker = false
    @State private var photoItem: PhotosPickerItem?
    @State private var previewImage: UIImage?
    @State private var isLoading = false
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .largeTitle()
                    .imageScale(.large)
                    .foregroundStyle(tint)
                
                Text(title)
                    .callout()
                    .padding(.top, 15)
                
                Text(subTitle)
                    .caption()
                    .foregroundStyle(.gray)
            }
            .opacity(previewImage == nil ? 1 : 0)
            .frame(width: size.width, height: size.height)
            .overlay {
                if let previewImage {
                    Image(uiImage: previewImage)
                        .resizable()
                        .scaledToFit()
                        .padding(15)
                }
            }
            /// Displaying Loading UI
            .overlay {
                if isLoading {
                    ProgressView()
                        .padding(10)
                        .background(.ultraThinMaterial, in: .rect(cornerRadius: 5))
                }
            }
            .animation(.snappy, value: isLoading)
            .animation(.snappy, value: previewImage)
            .contentShape(.rect)
            /// Implementing Drop Action and Retreving Dropped Image
            .dropDestination(for: Data.self) { items, location in
                if let firstItem = items.first, let droppedImage = UIImage(data: firstItem) {
                    /// Sending the Image using the callback
                    generateImageThumbnail(droppedImage, size)
                    onImageChange(droppedImage)
                    return true
                }
                
                return false
            } isTargeted: { _ in
                
            }
            .onTapGesture {
                showImagePicker.toggle()
            }
            .photosPicker(isPresented: $showImagePicker, selection: $photoItem)
            /// Let's Process the Selected Image
            .optionalViewModifier { contentView in
                if #available(iOS 17, *) {
                    contentView
                        .onChange(of: photoItem) { oldValue, newValue in
                            if let newValue {
                                extractImage(newValue, size)
                            }
                        }
                } else {
                    contentView
                        .onChange(of: photoItem) { newValue in
                            if let newValue {
                                extractImage(newValue, size)
                            }
                        }
                }
            }
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .fill(tint.opacity(0.08).gradient)
                    
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .stroke(tint, style: .init(lineWidth: 1, dash: [12]))
                        .padding(1)
                }
            }
        }
    }
    
    private func extractImage(
        _ photoItem: PhotosPickerItem,
        _ viewSize: CGSize
    ) {
        Task.detached {
            guard let imageData = try? await photoItem.loadTransferable(type: Data.self) else {
                return
            }
            
            /// UI Must be Updated on Main Thread
            await MainActor.run {
                if let selectedImage = UIImage(data: imageData) {
                    /// Creating Preview
                    generateImageThumbnail(selectedImage, viewSize)
                    /// Send Orignal Image to Callback
                    onImageChange(selectedImage)
                }
                
                self.photoItem = nil
            }
        }
    }
    
    func generateImageThumbnail(
        _ image: UIImage,
        _ size: CGSize
    ) {
        isLoading = true
        
        Task.detached {
            let thumbnailImage = await image.byPreparingThumbnail(ofSize: size)
            
            await MainActor.run {
                previewImage = thumbnailImage
                isLoading = false
            }
        }
    }
}

extension View {
    @ViewBuilder func optionalViewModifier<Content: View> (
        @ViewBuilder content: @escaping (Self) -> Content
    ) -> some View {
        content(self)
    }
}
