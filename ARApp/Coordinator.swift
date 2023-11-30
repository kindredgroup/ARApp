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
    
    var view: ARView?
    var collisionBeganObserver: Cancellable!
    var selectedObject: String = "ball"
    var objects = [Objects]()
    
    @MainActor func loadData(){
        // Load some json data
        JsonApi().getObjects { (objects) in
            self.objects = objects
            print(objects)
        }
        
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

    @MainActor @objc
    func handleTap(_ recognizer: UITapGestureRecognizer? = nil) {
        
        if (selectedObject == "bullet") {
            launchSphere()
        }
        if (selectedObject == "ball") {
            dropItem()
        }
        if (selectedObject == "load") {
            loadData()
        }
        if (selectedObject == "loadpins") {
            setupPins()
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
    
    
    @MainActor func setupPins(){
        guard let view = self.view else { return }
        
        print("Clearing Pins")
        let query = EntityQuery()
        // Ask the scene to perform the query and iterate over the returned
        view.scene.performQuery(query).forEach { entity in
            if (entity.name=="pin" || entity.name=="ball" || entity.name=="box") {
                entity.removeFromParent()
            }
        }
        
        // ** TODO bug where location is not set properly
        self.objects.forEach { c in
            createPin(x:c.x,y:c.y,z:c.z)
        }
    }
    
    @MainActor func createPin(x:Float, y:Float, z:Float){
        print ("Create Pin")
        guard let view = self.view else { return }
        
        let anchorEntity = AnchorEntity(world: [0,0,0])
        let cameraTranslation = view.cameraTransform.translation
        let cameraRotation = view.cameraTransform.rotation
        let cameraForwardVector: SIMD3<Float> = view.cameraTransform.matrix.forward
        let direction = cameraForwardVector * 2
 
        /*
        if let e = try? Entity.load(named: "Object1.reality") {
            e.name = "pin"
            e.setParent(anchorEntity)
            e.transform.translation += direction
            e.transform.translation += SIMD3(x: x, y: y, z: z)
        }
        */
        let e = createModel()
        e.name = "pin"
        e.setParent(anchorEntity)
        e.transform.translation += direction
        e.transform.translation += SIMD3(x: x, y: y, z: z)
        
        view.scene.addAnchor(anchorEntity)

    }
    
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
    
    @MainActor func dropItem(){
        guard let view = self.view else { return }
        print("Drop Item")
        // Load the "Box" scene from the "Experience" Reality File
        if let b = try? Experience.loadBox() {
            b.name = "box"
            view.scene.anchors.append(b)
        }
    }
}

extension float4x4 {
    var forward: SIMD3<Float> {
        normalize(SIMD3<Float>(-columns.2.x, -columns.2.y, -columns.2.z))
    }
}

func getDocumentsDirectory() -> URL {

let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
let documentsDirectory = paths[0]
return documentsDirectory

}
