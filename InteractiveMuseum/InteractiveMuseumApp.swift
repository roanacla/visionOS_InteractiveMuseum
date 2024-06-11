//
//  InteractiveMuseumApp.swift
//  InteractiveMuseum
//
//  Created by Roger Navarro Claros on 6/8/24.
//

import SwiftUI
import RealityKitContent

@main
struct InteractiveMuseumApp: App {
    
    init() {
        RealityKitContent.GestureComponent.registerComponent()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 0.75, height: 0.75, depth: 1, in: .meters )

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }.immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
