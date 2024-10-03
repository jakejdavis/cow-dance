//
//  AddButtonView.swift
//  CowDance
//
//  Created by Jake Davis on 03/10/2024.
//

import SwiftUI

struct AddButtonView: View {
    @Binding var isAddSheetPresented: Bool
    var onRandom: () -> Void = {}
    
    var body: some View {
        HStack(spacing: 4) {
            Button {
                onRandom()
            } label: {
                Image(systemName: "dice")
                    .font(.body.weight(.bold))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(.ultraThinMaterial, in: Circle())
            }
            
            Button {
                isAddSheetPresented = true
            } label: {
                Image(systemName: "plus")
                    .font(.body.weight(.bold))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(.ultraThinMaterial, in: Circle())
            }
        }
    }
}

struct AddButtonView_Previews: PreviewProvider {
    static var previews: some View {
        AddButtonView(isAddSheetPresented: .constant(false))
    }
}
