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
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            } else if item.importance == .important {
                ZStack {
                    Image(systemName: "circle")
                        .foregroundStyle(.red)
                    Image(systemName: "circle.fill")
                        .foregroundStyle(.red)
                        .opacity(0.1)
                    
                }
            } else {
                Image(systemName: "circle")
                    .foregroundStyle(Color(.systemGray))
            }
        }
        .font(.title2)
    }
}


