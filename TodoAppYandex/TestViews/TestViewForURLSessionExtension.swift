//
//  TestViewForURLSessionExtension.swift
//  TodoAppYandex
//
//  Created by Григорий Громов on 12.07.2024.
//

import SwiftUI

struct TestViewForURLSessionExtension: View {
    @StateObject var imageLoader = ImageLoader()
    @State var isLoading: Bool = false
    @State var image: Image?

    var body: some View {
        VStack {

            if !imageLoader.isLoading {
                Button("Show image") {
                    print("Нажата")
                    imageLoader.loadImage()
                }
            } else {
                ProgressView()
                Button("Cancel") {
                    print("Нажата кнопка отмены")
                    imageLoader.cancelImageLoad()
                }
            }

            if let image = imageLoader.image {
                image
                    .resizable()
                    .frame(width: 200, height: 200)
            } else if isLoading {
                ProgressView()
            }
        }
        .padding()
    }
}
