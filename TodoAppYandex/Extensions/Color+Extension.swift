//
//  Color+Extension.swift
//  TodoAppYandex
//
//  Created by Григорий Громов on 28.06.2024.
//

import Foundation
import SwiftUI

extension Color {
    
    func toHex() -> String {
        guard let components = UIColor(self).cgColor.components else {
            return ""
        }
        
        let red = String(format: "%02lX", Int(components[0] * 255.0))
        let green = String(format: "%02lX", Int(components[1] * 255.0))
        let blue = String(format: "%02lX", Int(components[2] * 255.0))
        
        return "#\(red)\(green)\(blue)"
    }
    

    
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
    
}


