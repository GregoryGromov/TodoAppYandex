//
//  View+Extensions.swift
//  TodoAppYandex
//
//  Created by Григорий Громов on 05.07.2024.
//

import Foundation
import SwiftUI

extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}
