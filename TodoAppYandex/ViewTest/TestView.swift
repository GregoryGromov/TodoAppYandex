//
//  TestView.swift
//  TodoAppYandex
//
//  Created by Григорий Громов on 25.06.2024.
//

import SwiftUI

struct TestView: View {
    
    @StateObject var viewModel = TestViewModel()
    
    var body: some View {
        VStack {
            input
            button
        }
    }
    
    var input: some View {
        TextField("Введите название дела:", text: $viewModel.name)
    }
    
    var button: some View {
        Button {
            viewModel.saveTodoItem()
        } label: {
            Text("Сохранить")
        }
    }
}

