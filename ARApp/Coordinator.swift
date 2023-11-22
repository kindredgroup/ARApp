//
//  Coordinator.swift
//  ARCounter
//
//  Created by Mike Griffin on 20/11/2023.
//

import Foundation
import SwiftUI
import RealityKit
import Combine

class Coordinator: NSObject {
    var view: ARView?
    var collisionBeganObserver: Cancellable!
    var selectedObject: String = "ball"
    
    @objc
    func handleLongPress(_ recognizer: UITapGestureRecognizer? = nil) {
        // Check if there is a view to work with
        guard let view = self.view else { return }

        // Obtain the location of a tap or touch gesture
        let tapLocation = recognizer!.location(in: view)

        // Checking if there's an entity at the tapped location within the view
        if let entity = view.entity(at: tapLocation) as? ModelEntity {
            
            print ("Long Press")
            print (entity.name)
  
            // Check if this entity is anchored to an anchor
            if let anchorEntity = entity.anchor {
                // Remove the model from the scene
                if (entity.name=="ball") {
                    //anchorEntity.removeFromParent()
                }
            }
        }
    }
    
    func launchSphere(){
        guard let view = self.view else { return }
        let anchorEntity = AnchorEntity(world: [0,0,0])
        let cameraTranslation = view.cameraTransform.translation
        let cameraRotation = view.cameraTransform.rotation
        
        let mesh = MeshResource.generateSphere(radius: 0.025)
        let material = SimpleMaterial(color: .init(red: 0.8, green: 0, blue: 0, alpha: 1), isMetallic: true)
        let sphere = ModelEntity(mesh: mesh, materials: [material])
        let shape = ShapeResource.generateSphere(radius: 0.025)
        sphere.collision = CollisionComponent(shapes: [shape])
        let spherePhysicsMaterial = PhysicsMaterialResource.generate(friction: 0.055, restitution: 0.85)
        let kinematics: PhysicsBodyComponent = .init(massProperties: .default, material: spherePhysicsMaterial, mode: .dynamic)
        sphere.components.set(kinematics)
        sphere.transform.translation = cameraTranslation
        sphere.transform.rotation = cameraRotation
        sphere.name="ball"
        sphere.setParent(anchorEntity)
        view.scene.addAnchor(anchorEntity)
        let cameraForwardVector: SIMD3<Float> = view.cameraTransform.matrix.forward
        let direction = cameraForwardVector * 200
        sphere.addForce(direction, relativeTo: nil)
        print("Added sphere")
    }
    
    func dropItem(){
        guard let view = self.view else { return }
        let anchorEntity = AnchorEntity(world: [0,0,0])
        let cameraTranslation = view.cameraTransform.translation

        if let e = try? Entity.loadModel(named: "Bowling_Pin") {
            let size = e.visualBounds(relativeTo: e).extents
            let boxShape = ShapeResource.generateBox(size: size)
            e.collision = CollisionComponent(shapes: [boxShape])
            let kinematics: PhysicsBodyComponent = .init(massProperties: .default,material: nil, mode: .dynamic)
            e.components.set(kinematics)
            e.transform.translation = cameraTranslation
            e.name = "pin"
            e.setParent(anchorEntity)
            view.scene.addAnchor(anchorEntity)
            print("Added pin")
        }
    }
    
    @objc
    func handleTap(_ recognizer: UITapGestureRecognizer? = nil) {
        
        if (selectedObject == "bullet") {
            launchSphere()
        }
        if (selectedObject == "ball") {
            dropItem()
        }
        guard let view = self.view else { return }

        // Obtain the location of a tap or touch gesture
        let tapLocation = recognizer!.location(in: view)

        // Checking if there's an entity at the tapped location within the view
        if let entity = view.entity(at: tapLocation) as? ModelEntity {
            print ("Tap")
            print (entity.name)
        }
    }
}

extension float4x4 {
    var forward: SIMD3<Float> {
        normalize(SIMD3<Float>(-columns.2.x, -columns.2.y, -columns.2.z))
    }
}
