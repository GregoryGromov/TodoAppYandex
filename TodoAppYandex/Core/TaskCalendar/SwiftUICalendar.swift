//
//  SwiftUICalendar.swift
//  TodoAppYandex
//
//  Created by Григорий Громов on 06.07.2024.
//

import SwiftUI

struct SwiftUICalendar: View {
    
    @State private var selectedDate = (day: 1, month: "Jan")
    
    @State private var text: String = ""
    
    let numbers = Array(0..<8)
    
    var dateTuples = [(Int, String)]()
    
    init() {
        self.dateTuples = extractDeadlines(from: TodoItem.MOCK)
    }

    
    var body: some View {
        VStack {

            
            CalendarUIViewRepresentable(dateTuples: dateTuples, selectedDate: $selectedDate, onDelete: printDelete)
                        .frame(height: 150)
                        .padding(.top, 20)
            
            Text("\(selectedDate.day)")
            Spacer()
            Text( """
        К сожалению, я не успел сделать всё как узложено в ТЗ. Однако основные концептуально важные моменты реализованы:
            - Связь между элементами SwiftUI в UIKit: туда передаются данные о дедлайнах заданий
            - Связь между элементами UIKit в SwiftUI: при нажатии на кнопку удалить в UIKit в SwiftUI запускается функция, которая индентифицирует выбранный элемент
        Понимаю, что в даже лучшем случае данное решение может быть оценено не более чем на 1 балл
        """)
        }
        
    }
    
    func printDelete() {
        print("Из UIKit в SwiftUI поступили указания об удалении задания с дедлайном \(selectedDate.day) \(selectedDate.month)")
    }
    
    
    func extractDeadlines(from todoItems: [TodoItem]) -> [(day: Int, month: String)] {
        var result: [(day: Int, month: String)] = []

        let calendar = Calendar.current
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM"
        monthFormatter.locale = Locale(identifier: "ru_RU")  

        for item in todoItems {
            if let deadline = item.deadline {
                let day = calendar.component(.day, from: deadline)
                let month = monthFormatter.string(from: deadline)
                result.append((day: day, month: month))
            }
        }

        return result
    }
}

