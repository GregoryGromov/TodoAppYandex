//
//  TodoItemListLabel.swift
//  TodoAppYandex
//
//  Created by Григорий Громов on 05.07.2024.
//

import SwiftUI

struct TodoCheckmarkLabel: View {

    let item: TodoItem

    var body: some View {
        HStack {
            if item.isDone {
                ImageCollection.checkmarkCircle
                    .foregroundStyle(.green)
            } else if item.importance == .important {
                ZStack {
                    ImageCollection.circle
                        .foregroundStyle(.red)
                    ImageCollection.circleFill
                        .foregroundStyle(.red)
                        .opacity(0.1)

                }
            } else {
                ImageCollection.circle
                    .foregroundStyle(Color(.systemGray))
            }
        }
        .font(.title2)
    }
}
