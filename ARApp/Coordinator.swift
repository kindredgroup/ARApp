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

class Coordinator: NSObject, URLSessionDownloadDelegate {
    var view: ARView?
    var collisionBeganObserver: Cancellable!
    var selectedObject: String = "ball"
    var objects = [Objects]()
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("Download finished: \(location)")
        // Create The Filename
        let fileURL = getDocumentsDirectory().appendingPathComponent("ExperienceDownload.reality")
        // Copy It To The Documents Directory
        do {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                // delete file
                do {
                    try FileManager.default.removeItem(atPath: fileURL.path)
                    print("MODEL deleted file")
                } catch {
                    print("MODEL Could not delete file, probably read-only filesystem")
                }
            }
            try FileManager.default.copyItem(at: location, to: fileURL)

            print("MODEL Successfuly Saved File \(fileURL)")
        } catch {
            print("MODEL Error Saving: \(error)")
        }
    }
    
    @MainActor func loadData(){
        // Load some json data
        JsonApi().getObjects { (objects) in
            self.objects = objects
            print(objects)
        }
        
        // Download reality file
        let url = URL(string:"https://github.com/kindredgroup/ARApp/raw/master/ARApp/Assets/Object1.reality")!
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil

        let downloadSession = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        let downloadTask = downloadSession.downloadTask(with: url)
        downloadTask.resume()
    }
    
    @objc
    func handleLongPress(_ recognizer: UITapGestureRecognizer? = nil) {
        // Check if there is a view to work with
        guard let view = self.view else { return }
        print ("Long Press")

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
                    anchorEntity.removeFromParent()
                }
            }
        }
    }

    @MainActor @objc
    func handleTap(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: view)
        guard let view = self.view else { return }
        
        if (selectedObject == "ball") {
            launchSphere()
        }
        if (selectedObject == "text") {
            if let result = view.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .any).first {
                let resultAnchor = AnchorEntity(world: result.worldTransform)
                let textContent = "GRIFFIN INC!"
                let text = createModelText(text:textContent)
                var width = Float(textContent.count) as Float
                width = (width + 1) * 0.12
                let panel = createModelPlane(color:randomColor(), width:width, depth:0.25)
                resultAnchor.addChild(panel)
                resultAnchor.addChild(text)
                view.scene.addAnchor(resultAnchor)
            }
        }
        if (selectedObject == "other") {
            if let result = view.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .any).first {
                setupList(transform: result.worldTransform)
            }
        }
        if (selectedObject == "setuppins") {
            if let result = view.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .any).first {
                setupPins(transform: result.worldTransform)
            }
        }

        // Checking if there's an entity at the tapped location within the view
        if let entity = view.entity(at: tapLocation) as? ModelEntity {
            print ("Tap")
            print (entity.name)
        }
    }
    
    @MainActor func setupList(transform: simd_float4x4){
        clear()
        self.objects.forEach { c in
            createText(textContent:c.name, transform: transform, x:c.x, y:c.y, z:c.z)
        }
    }
    
    func clear(){
        guard let view = self.view else { return }
        print("Clearing Pins")
        let query = EntityQuery()
        // Ask the scene to perform the query and iterate over the returned
        view.scene.performQuery(query).forEach { entity in
            if (entity.name=="panel" || entity.name=="text" || entity.name=="pin" || entity.name=="ball" || entity.name=="box") {
                entity.removeFromParent()
            }
        }
    }
    
    @MainActor func setupPins(transform: simd_float4x4){
        guard let view = self.view else { return }
        clear()
        self.objects.forEach { c in
            createPin(transform: transform, x:c.x, y:c.y, z:c.z)
        }
    }
    
    @MainActor func createText(textContent:String, transform: simd_float4x4,x:Float, y:Float, z:Float){
        print ("Create Text")
        guard let view = self.view else { return }

        let resultAnchor = AnchorEntity(world: transform)
        let text = createModelText(text: textContent)
        var width = Float(textContent.count) as Float
        width = (width + 1) * 0.12
        let panel = createModelPlane(color:randomColor(), width:width, depth:0.25)
        resultAnchor.addChild(panel)
        resultAnchor.addChild(text)
        panel.transform.translation += SIMD3(x: x, y: y, z: z)
        text.transform.translation += SIMD3(x: x, y: y, z: z)
        view.scene.addAnchor(resultAnchor)
    }
    
    @MainActor func createPin(transform: simd_float4x4,x:Float, y:Float, z:Float){
        print ("Create Pin")
        guard let view = self.view else { return }
        
        let anchorEntity = AnchorEntity(world: transform)
        let e = createModel3()
        e.name = "pin"
        e.setParent(anchorEntity)
        e.transform.translation += SIMD3(x: x, y: y, z: z)
        view.scene.addAnchor(anchorEntity)
    }
    
    // create model from reality downloaded reality file
    func createModel() -> Entity {
        var e:Entity = Entity()
        let url = getDocumentsDirectory().appendingPathComponent("ExperienceDownload.reality")
        print("MODEL path = \(url)")
        do {
            let model = try Entity.load(contentsOf: url)
            e = model
        } catch {
            print(error)
            print("MODEL Fail loading entity.")
        }

        e.name = "object1"
        return e
    }
    
    // create model from Experience.rcproject file
    @MainActor func createModel2() -> Entity {
        var e:Entity = Entity()
        if let b = try? Experience.loadPicture() {
            b.name = "picture"
            e = b
        }
        return e
    }
    
    // create model from local reality file
    func createModel3() -> Entity {
        var e:Entity = Entity()
        if let x = try? Entity.load(named: "Object2.reality") {
            e = x
        }
        e.name = "picture"
        return e
    }
    
    // create panel from plane
    func createModelPlane(color:UIColor, width:Float, depth:Float) -> Entity {
        let mesh = MeshResource.generatePlane(width: width, depth: depth)
        let material = SimpleMaterial(color: color, isMetallic: true)
        let shape = ShapeResource.generateSphere(radius: 0.1)
        let e = ModelEntity(mesh: mesh, materials: [material], collisionShape:shape, mass: 0.5)
        let p = PhysicsMaterialResource.generate(friction: 0.055, restitution: 0.85)
        let kinematics: PhysicsBodyComponent = .init(massProperties: .default, material: p, mode: .static)
        e.components.set(kinematics)
        e.name = "panel"
        return e
    }
    
    func createModelText(text:String) -> Entity {
        let lineHeight: CGFloat = 0.2
        let font = MeshResource.Font.systemFont(ofSize: lineHeight)
        let textMesh = MeshResource.generateText(text, extrusionDepth: Float(lineHeight * 0.1), font: font, alignment:.center)
        let textMaterial = SimpleMaterial(color: .white, isMetallic: true)
        let e = ModelEntity(mesh: textMesh, materials: [textMaterial])
        let radians = -90.0 * Float.pi / 180.0
        e.transform.rotation *= simd_quatf(angle: radians, axis: SIMD3<Float>(1,0,0))
        let p = PhysicsMaterialResource.generate(friction: 0.055, restitution: 0.85)
        let kinematics: PhysicsBodyComponent = .init(massProperties: .default, material: p, mode: .static)
        e.components.set(kinematics)
        e.name="text"
        // ** TODO work length and move
        let width = (e.model?.mesh.bounds.max.x)! - (e.model?.mesh.bounds.min.x)!
        e.transform.translation = [width / 2 * -1, 0, 0.1]
        return e
    }

    func launchSphere(){
        guard let view = self.view else { return }
        let anchorEntity = AnchorEntity(world: [0,0,0])
        let cameraTranslation = view.cameraTransform.translation
        let cameraRotation = view.cameraTransform.rotation
        
        let mesh = MeshResource.generateSphere(radius: 0.1)
        let material = SimpleMaterial(color: .init(red: 0.2, green: 0.2, blue: 0.2, alpha: 1), isMetallic: true)
        let shape = ShapeResource.generateSphere(radius: 0.1)
        let sphere = ModelEntity(mesh: mesh, materials: [material], collisionShape:shape, mass: 0.5)
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
}

extension float4x4 {
    var forward: SIMD3<Float> {
        normalize(SIMD3<Float>(-columns.2.x, -columns.2.y, -columns.2.z))
    }
}

func randomColor() -> UIColor {
    let red = CGFloat.random(in: 0...1)
    let green = CGFloat.random(in: 0...1)
    let blue = CGFloat.random(in: 0...1)
    return UIColor(red: red, green: green, blue: blue, alpha: 1)
}

func getDocumentsDirectory() -> URL {
let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
let documentsDirectory = paths[0]
return documentsDirectory
}
