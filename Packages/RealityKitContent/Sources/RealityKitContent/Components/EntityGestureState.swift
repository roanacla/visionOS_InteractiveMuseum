//
//  File.swift
//  
//
//  Created by Roger Navarro Claros on 6/9/24.
//

import RealityKit
import SwiftUI

public class EntityGestureState {
    
    /// The entity currently being dragged if a gesture is in progress.
    var targetedEntity: Entity?
    
    // MARK: - Drag
    
    /// The starting position.
    var dragStartPosition: SIMD3<Float> = .zero
    
    /// Marks whether the app is currently handling a drag gesture.
    var isDragging = false
    
    /// When `rotateOnDrag` is`true`, this entity acts as the pivot point for the drag.
    var pivotEntity: Entity?
    
    var initialOrientation: simd_quatf?
    
    // MARK: - Magnify
    
    /// The starting scale value.
    var startScale: SIMD3<Float> = .one
    
    /// Marks whether the app is currently handling a scale gesture.
    var isScaling = false
    
    // MARK: - Rotation
    
    /// The starting rotation value.
    var startOrientation = Rotation3D.identity
    
    /// Marks whether the app is currently handling a rotation gesture.
    var isRotating = false
    
    // MARK: - Singleton Accessor
    
    /// Retrieves the shared instance.
    static let shared = EntityGestureState()
}

