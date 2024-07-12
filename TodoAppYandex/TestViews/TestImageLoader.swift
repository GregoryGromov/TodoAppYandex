//
//  TestImageLoader.swift
//  TodoAppYandex
//
//  Created by Григорий Громов on 12.07.2024.
//

import Foundation
import SwiftUI

final class ImageLoader: ObservableObject, @unchecked Sendable {
    @Published var image: Image?

    @Published var isLoading = false

    var imageLoadTask: Task<Void, Never>?

    func loadImage() {
        imageLoadTask = Task {

            await MainActor.run {
                self.isLoading = true
            }

            await Task.sleep(3 * 1_000_000_000)

            do {
                let urlRequest = URLRequest(url: getUrl())

                let (data, _) = try await URLSession.shared.dataTask(for: urlRequest)

                guard let uiImage = UIImage(data: data) else {
                    throw URLError(.cannotDecodeContentData)
                }

                let fetchedImage = Image(uiImage: uiImage)

                await MainActor.run {
                    self.isLoading = false
                    print("Картинка поставлена")
                    self.image = fetchedImage
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                }
                print(error)
            }
        }

    }

    func cancelImageLoad() {
        imageLoadTask!.cancel()
    }

    func getUrl() -> URL {
        let urlString = "https://dynamic-media-cdn.tripadvisor.com/media/photo-o/0d/aa/48/fe/vichy.jpg?w=1400&h=1400&s=1"
        guard let url = URL(string: urlString) else { fatalError("invalid urlString") }
        return url
    }
}
