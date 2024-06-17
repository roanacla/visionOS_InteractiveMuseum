//
//  ContentView.swift
//  InteractiveMuseum
//
//  Created by Roger Navarro Claros on 6/8/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {

    @State private var showImmersiveSpace = false
    @State private var immersiveSpaceIsShown = false

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var body: some View {
        VStack {
            Text("Welcome to the")
                .font(.extraLargeTitle2)
                .padding()
            Image("Apple Museum Logo")
                .resizable()
                .scaledToFit()
                .frame(width: 1200, height: 200)
                .padding([.bottom], 100)
                .padding([.trailing], 80)
            
            Button(action: {
                showImmersiveSpace.toggle()
            }, label: {
                if showImmersiveSpace {
                    Text("Close")
                        .font(.extraLargeTitle2)
                        .padding()
                } else {
                    Text("Enter")
                        .font(.extraLargeTitle2)
                        .padding()
                }
            })
            .padding(40)
        }
        .padding()
        .onChange(of: showImmersiveSpace) { _, newValue in
            Task {
                if newValue {
                    switch await openImmersiveSpace(id: "ImmersiveSpace") {
                    case .opened:
                        immersiveSpaceIsShown = true
                    case .error, .userCancelled:
                        fallthrough
                    @unknown default:
                        immersiveSpaceIsShown = false
                        showImmersiveSpace = false
                    }
                } else if immersiveSpaceIsShown {
                    await dismissImmersiveSpace()
                    immersiveSpaceIsShown = false
                }
            }
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
