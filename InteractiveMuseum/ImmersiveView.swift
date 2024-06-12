//
//  ImmersiveView.swift
//  InteractiveMuseum
//
//  Created by Roger Navarro Claros on 6/8/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    @State var isObjectSelected = false
    @State var currentEntity: Entity?
    @State var previousPosition: SIMD3<Float> = [0,0,0]
    
    var body: some View {
        RealityView { content, attachments in
            // Add the initial RealityKit content
            if let immersiveContentEntity = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                content.add(immersiveContentEntity)

                // Add an ImageBasedLight for the immersive content
                guard let resource = try? await EnvironmentResource(named: "ImageBasedLight") else { return }
                let iblComponent = ImageBasedLightComponent(source: .single(resource), intensityExponent: 0.25)
                immersiveContentEntity.components.set(iblComponent)
                immersiveContentEntity.components.set(ImageBasedLightReceiverComponent(imageBasedLight: immersiveContentEntity))

                // Put skybox here.  See example in World project available at
                // https://developer.apple.com/
            }
        } update: { content, attachments in
            if let attachmentEntity = attachments.entity(for: "h1") {
                content.add(attachmentEntity)
//                currentEntity?.addChild(attachmentEntity)
                attachmentEntity.setPosition([0,-10,10], relativeTo: currentEntity)
            }
        } attachments: {
            if isObjectSelected {
                Attachment(id: "h1") {
                    HStack {
                        Button(action: {
                            
                        }, label: {
                            Text("Scale")
                        })
                        Button(action: {
                            
                        }, label: {
                            Text("Rotate")
                        })
                    }
                    .padding()
                    .background(Color.gray.opacity(0.5))
                    .cornerRadius(10)
                    
                    VStack {
                        Button(action: {
                            currentEntity?.setPosition(previousPosition, relativeTo: nil)
                            currentEntity = nil
                            previousPosition = [0,0,0]
                            isObjectSelected = false
                        }, label: {
                            Text("Close")
                        })
                        Button(action: {
                            
                        }, label: {
                            Text("Rotate")
                        })
                    }
                    .padding()
                    .background(Color.gray.opacity(0.5))
                    .cornerRadius(10)
                }
            }
        }
        .installGestures()
        .gesture(tapGesture)
    }
    
    var tapGesture: some Gesture {
        TapGesture()
            .targetedToAnyEntity()
            .onEnded { value in
                isObjectSelected = true
                currentEntity = value.entity
                previousPosition = value.entity.position
                value.entity.setPosition([0, 1.5, -1], relativeTo: nil)
                // position object 0.5 meters in front of user.
            }
    }
}

#Preview(immersionStyle: .full) {
    ImmersiveView()
}
