//
//  Checkbox.swift
//  CowDance
//
//  Created by Jake Davis on 03/10/2024.
//

import Foundation
import SwiftUI

struct CheckboxFieldView: View {
    let text: String
    let checked: Bool
    let action: () -> Void
    
    init(text: String, checked: Bool, action: @escaping () -> Void) {
        self.text = text
        self.checked = checked
        self.action = action
    }
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .stroke(Color.primary, lineWidth: 1)
                    .frame(width: 20, height: 20)
                
                if checked {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 14, height: 14)
                }
            }
            
            
            Text(self.text)
        } .onTapGesture {
            action()
        }
    }
}
