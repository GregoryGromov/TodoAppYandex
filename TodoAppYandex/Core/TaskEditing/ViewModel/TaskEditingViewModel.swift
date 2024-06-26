//
//  TaskEditingViewModel.swift
//  TodoAppYandex
//
//  Created by Григорий Громов on 24.06.2024.
//
import SwiftUI
import Foundation

class TaskEditingViewModel: ObservableObject {
    
    @Published var text = ""
    @Published var selectedImportance: Importance = .ordinary
    
    @Published var deadlineSet = false {
        didSet {
            if !deadlineSet {
                showCalendar = false
            }
        }
    }
    @Published var showCalendar = false
    @Published var deadline: Date = Date().addingTimeInterval(86_400) // 60 * 60 * 24 = 86400

    
    
    func getPickerPreview(for importance: Importance) -> some View {
        switch importance {
        case .unimportant:
            return Image(systemName: "arrow.down").eraseToAnyView()
        case .ordinary:
            return Text("нет").eraseToAnyView()
        case .important:
            return Image(systemName: "exclamationmark.2").eraseToAnyView()
        }
    }
    
    
    
    
    
    
}



extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}
