//
//  TipContainerView.swift
//  InteractiveMuseum
//
//  Created by Roger Navarro Claros on 6/14/24.
//

import SwiftUI

struct TipContainerView: View {
    var body: some View {
        HStack {
            Label(title: {
                Text("Pinch & Drag")
            }, icon: {
                Image("Pinch & Drag")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            })
            .padding([.leading])
            Spacer()
            Label(title: {
                Text("Rotate")
            }, icon: {
                Image("Rotate")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            })
            .padding([.trailing])
        }
        .padding(32)
        .glassBackgroundEffect()
        .cornerRadius(10)
        .frame(width: 500, height: 100)
    }
}

#Preview {
    TipContainerView()
}
