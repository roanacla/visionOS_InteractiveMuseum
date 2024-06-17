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
    @State var currentEntity: Entity?
    @State var sliderValue = 1.0
    
    @State var originalPosition: SIMD3<Float> = [0,0,0]
    @State var originalSize: SIMD3<Float> = [0,0,0]
    @State var originalOrientation: simd_quatf = .init()
    
    @State var mainEntity: Entity?
    
    //MARK: - Gestures
    var tapGesture: some Gesture {
        TapGesture()
            .targetedToAnyEntity()
            .onEnded { value in
                guard currentEntity == nil else { return }
                currentEntity = value.entity
                originalPosition = value.entity.position
                originalSize = value.entity.scale
                originalOrientation = value.entity.orientation
                value.entity.setPosition([0, 0.70, -1], relativeTo: nil)
                value.entity.components[GestureComponent.self]?.canDrag = true
            }
    }
    //MARK: - Functions
    func resetEntityAndEditingTools() {
        currentEntity?.setPosition(originalPosition, relativeTo: nil)
        currentEntity?.components[GestureComponent.self]?.canDrag = false
        currentEntity?.setScale(originalSize, relativeTo: nil)
        currentEntity?.setOrientation(originalOrientation, relativeTo: nil)
        currentEntity = nil
        originalPosition = [0,0,0]
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
    
    func tilt(entity: Entity, by degrees: Float, relativeTo relativeToEntity: Entity? = nil) {
        let rotationAngleDegrees: Float = degrees
        let rotationAngleRadians = rotationAngleDegrees * .pi / 180
        let rotationQuaternion = simd_quatf(angle: rotationAngleRadians, axis: SIMD3<Float>(1, 0, 0))

        entity.setOrientation(rotationQuaternion, relativeTo: relativeToEntity)
    }
    
    func setPosition(_ position: SIMD3<Float>, to entity: Entity, relativeTo relativeToEntity: Entity? = nil) {
        entity.setPosition(position, relativeTo: relativeToEntity)
    }
    
    func playSound() async {
        guard let entity = await mainEntity?.findEntity(named: "AmbientAudio") else { return }
        guard let resource = try? await AudioFileResource(named: "/Root/background_sound_m4a", from: "Immersive.usda", in: realityKitContentBundle) else { return }
        await entity.prepareAudio(resource).play()
    }
    
    //MARK: - Body
    var body: some View {
        RealityView { content, attachments in
            // Add the initial RealityKit content
            if let immersiveContentEntity = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                self.mainEntity = immersiveContentEntity
                content.add(immersiveContentEntity)

                // Add an ImageBasedLight for the immersive content
                guard let resource = try? await EnvironmentResource(named: "ImageBasedLight") else { return }
                let iblComponent = ImageBasedLightComponent(source: .single(resource), intensityExponent: 0.25)
                immersiveContentEntity.components.set(iblComponent)
                immersiveContentEntity.components.set(ImageBasedLightReceiverComponent(imageBasedLight: immersiveContentEntity))
                
                await playSound()
            }
        } update: { content, attachments in
            if let attachmentEntity = attachments.entity(for: "EntityController") {
                content.add(attachmentEntity)
                setPosition([0,0.5,-0.7], to: attachmentEntity)
                tilt(entity: attachmentEntity, by: -30)
            }
            if let fog = content.entities[0].findEntity(named: "ParticleEmitter"), let currentEntity {
                fog.components[ParticleEmitterComponent.self]?.isEmitting = true
                fog.components[ParticleEmitterComponent.self]?.restart()
                
                //Accessibility announcement
                AccessibilityNotification.Announcement("An object is been selected").post()
            }
        } attachments: {
            if currentEntity != nil {
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
        .animation(.easeIn(duration: 0.5), value: true)
        .onChange(of: sliderValue) { oldValue, newValue in
            scaleEntity(by: getSizeDifference(oldValue: oldValue, newValue: newValue))
        }
    }
}

#Preview(immersionStyle: .full) {
    ImmersiveView()
}
