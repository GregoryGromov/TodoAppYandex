//
//  TestViewForURLSessionExtension.swift
//  TodoAppYandex
//
//  Created by Григорий Громов on 12.07.2024.
//

import SwiftUI
import CocoaLumberjackSwift

struct TestViewForURLSessionExtension: View {
    @StateObject var imageLoader = ImageLoader()
    @State var isLoading: Bool = false
    @State var image: Image?

    var body: some View {
        VStack {

            if !imageLoader.isLoading {
                Button("Show image") {
                    DDLogInfo("'Show image' button pressed")
                    imageLoader.loadImage()
                }
            } else {
                ProgressView()
                Button("Cancel") {
                    DDLogInfo("'Cancel' button pressed")
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
