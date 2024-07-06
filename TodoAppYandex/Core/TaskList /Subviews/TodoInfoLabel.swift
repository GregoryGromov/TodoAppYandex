//
//  TodoInfoLabel.swift
//  TodoAppYandex
//
//  Created by Григорий Громов on 05.07.2024.
//

import SwiftUI

struct TodoInfoLabel: View {
    
    let item: TodoItem
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 2) {
                if item.importance == .important && !item.isDone {
                    Image(systemName: "exclamationmark.2")
                        .foregroundStyle(.red)
                        .fontWeight(.bold)
                }
                Text(item.text)
                    .strikethrough(item.isDone ? true : false)
                    .opacity(item.isDone ? 0.4 : 1)
                
                
                
                if let colorString = item.color {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundStyle(Color(hex: colorString))
                    //
                        .frame(width: 50, height: 5)
                }
                
                
            }
            
            if !item.isDone {
                if let deadline = item.deadline {
                    HStack(spacing: 2) {
                        Image(systemName: "calendar")
                        Text(deadline.dayMonth)
                        Spacer()
                    }
                    .opacity(0.4)
                    .font(.caption)
                }
            }
            
        }
        Spacer()
        Image(systemName: "chevron.right")
            .foregroundStyle(Color(.systemGray3))
    }
}


