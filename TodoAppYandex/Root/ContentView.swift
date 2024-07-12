//
//  ContentView.swift
//  TodoAppYandex
//
//  Created by Григорий Громов on 22.06.2024.
//

import SwiftUI
import CocoaLumberjackSwift

struct ContentView: View {

    var body: some View {

//        TestView()
//        Test5()
//        TestoView()

//        ColorPickerTest()

//        Test3()
//        TaskEditingView(mode: .create)

//        Test5()

//        TaskListView()

//        Test(mode: .create, todoItems: $d)

//        Test()

//        TestMain()

//        TestViewForURLSessionExtension()
        TaskListView()
            .onAppear {
                DDLogInfo("ContentView appeared")
                DDLogDebug("This is a debug message")
                DDLogWarn("This is a warning message")
                DDLogError("This is an error message")
            }

    }
}
