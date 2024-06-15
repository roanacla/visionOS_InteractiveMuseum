//
//  ScaleSliderView.swift
//  InteractiveMuseum
//
//  Created by Roger Navarro Claros on 6/14/24.
//

import SwiftUI

struct ScaleSliderView: View {
    @Binding var sliderValue: Double
    
    var body: some View {
        Slider(
            value: $sliderValue,
            in: 1...2,
            step: 0.1
        ) {
            Text("ITEM ZOOM LEVEL")
        } minimumValueLabel: {
            Text("1x")
        } maximumValueLabel: {
            Text("2x")
        }
        .padding(32)
        .glassBackgroundEffect()
        .cornerRadius(10)
        .frame(width: 500)
    }
}

#Preview {
    ScaleSliderView(sliderValue: .constant(1.0))
}
