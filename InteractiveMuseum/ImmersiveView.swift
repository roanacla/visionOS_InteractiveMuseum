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
    
    //MARK: - Gestures
    var tapGesture: some Gesture {
        TapGesture()
            .targetedToAnyEntity()
            .onEnded { value in
                isObjectSelected = true
                currentEntity = value.entity
                previousPosition = value.entity.position
                previousSize = value.entity.scale
                value.entity.setPosition([0, 0.6, -1], relativeTo: nil)
                value.entity.components[GestureComponent.self]?.canDrag = true
                // position object 0.5 meters in front of user.
            }
    }
    //MARK: - Functions
    func resetEntityAndEditingTools() {
        currentEntity?.setPosition(previousPosition, relativeTo: nil)
        currentEntity?.components[GestureComponent.self]?.canDrag = false
        currentEntity?.setScale(previousSize, relativeTo: nil)
        currentEntity = nil
        previousPosition = [0,0,0]
        isObjectSelected = false
        sliderValue = 1.0
    }
    
    func scaleEntity(by sizeDifference: Float) {
        guard let currentEntity else { return }
        currentEntity.scale *= SIMD3<Float>(repeating: sizeDifference)
    }
    
    func getSizeDifference(oldValue: Double, newValue: Double) -> Float {
        let (min, max) = (min(oldValue, newValue), max(oldValue, newValue))
        return abs(Float(max - min) + (max == oldValue ? -1 : 1))
    }
    
    //MARK: - Body
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
                attachmentEntity.setPosition([0,0.5,-0.7], relativeTo: attachmentEntity.parent)
                let rotationAngleDegrees: Float = -30
                let rotationAngleRadians = rotationAngleDegrees * .pi / 180
                let rotationQuaternion = simd_quatf(angle: rotationAngleRadians, axis: SIMD3<Float>(1, 0, 0))

                attachmentEntity.setOrientation(rotationQuaternion, relativeTo: nil)
            }
        } attachments: {
            if isObjectSelected {
                Attachment(id: "EntityController") {
                    TipContainerView()
                    
                    ScaleSliderView(sliderValue: $sliderValue)
                    
                    Button(action: {
                        resetEntityAndEditingTools()
                    }, label: {
                        Text("Close")
                    })
                }
            }
        }
        .installGestures()
        .gesture(tapGesture)
        .onChange(of: sliderValue) { oldValue, newValue in
            scaleEntity(by: getSizeDifference(oldValue: oldValue, newValue: newValue))
        }
    }
}

#Preview(immersionStyle: .full) {
    ImmersiveView()
}
