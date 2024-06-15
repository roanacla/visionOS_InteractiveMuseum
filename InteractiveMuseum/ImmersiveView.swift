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
    @State var sliderValue = 1.0
    @State var previousSize: SIMD3<Float> = [0,0,0]
    
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
            if let attachmentEntity = attachments.entity(for: "EntityController") {
                content.add(attachmentEntity)
                attachmentEntity.setPosition([0,-20,10], relativeTo: currentEntity)
            }
        } attachments: {
            if isObjectSelected {
                Attachment(id: "EntityController") {
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
                    
                    Button(action: {
                        currentEntity?.setPosition(previousPosition, relativeTo: nil)
                        currentEntity?.components[GestureComponent.self]?.canDrag = false
                        currentEntity?.setScale(previousSize, relativeTo: nil)
                        currentEntity = nil
                        previousPosition = [0,0,0]
                        isObjectSelected = false
                        sliderValue = 1.0
                    }, label: {
                        Text("Close")
                    })
                }
            }
        }
        .installGestures()
        .gesture(tapGesture)
        .onChange(of: sliderValue) { oldValue, newValue in
            let (min, max) = (min(oldValue, newValue), max(oldValue, newValue))
            let diff = abs(Float(max - min) + (max == oldValue ? -1 : 1))
            currentEntity?.scale *= SIMD3<Float>(repeating: diff)
        }
    }
    
    var tapGesture: some Gesture {
        TapGesture()
            .targetedToAnyEntity()
            .onEnded { value in
                isObjectSelected = true
                currentEntity = value.entity
                previousPosition = value.entity.position
                previousSize = value.entity.scale
                value.entity.setPosition([0, 1.5, -1], relativeTo: nil)
                value.entity.components[GestureComponent.self]?.canDrag = true
                // position object 0.5 meters in front of user.
            }
    }
}

#Preview(immersionStyle: .full) {
    ImmersiveView()
}
