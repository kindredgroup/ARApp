import SwiftUI
import RealityKit
import Combine

struct ARViewContainer: UIViewRepresentable {
    
    @ObservedObject var selectedObject: SelectedObject
    @State var comments = [Comments]()
    var a: ARView = ARView(frame: .zero)
    let tableAnchor = AnchorEntity(.plane(.horizontal, classification: .table, minimumBounds: [0.5, 0.5]))
    let floorAnchor = AnchorEntity(.plane(.horizontal, classification: .floor, minimumBounds: [0.5, 0.5]))
    
    func makeCoordinator() -> Coordinator {
        let c: Coordinator = Coordinator()
        c.collisionBeganObserver = a.scene.subscribe(
          to: CollisionEvents.Began.self
        ) { event in
                print("collision started")
                print(event.entityA.name)
                print(event.entityB.name)
            if (event.entityA.name=="ball" && event.entityB.name=="pin") {
                print("BOOOOOOOM!")
                if let anchorEntity = event.entityA.anchor {
                    // Remove the model from the scene
                    //anchorEntity.removeFromParent()
                }
                if let anchorEntity = event.entityB.anchor {
                    // Remove the model from the scene
                    //anchorEntity.removeFromParent()
                }
            }
        }
        return c
    }
    
    func makeUIView(context: Context) -> ARView {
        // Load some json data
        JsonApi().getUserComments { (comments) in
            self.comments = comments
        }
        //a.debugOptions = [.showAnchorOrigins, .showPhysics]
        createView(uiView:a)
        return a
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        context.coordinator.view = uiView
        context.coordinator.selectedObject = selectedObject.name
        
        let longPressGesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleLongPress(_:)))
        uiView.addGestureRecognizer(longPressGesture)
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        uiView.addGestureRecognizer(tapGesture)
        setupPins()
    }
    
    func setupPins(){
        
        let query = EntityQuery()
        // Ask the scene to perform the query and iterate over the returned
        a.scene.performQuery(query).forEach { entity in
            if (entity.name=="pin" || entity.name=="ball") {
                entity.removeFromParent()
            }
        }

        var x = Float()
        var z = Float()
        repeat {
            x += 0.5
            createPin(x:x,z:z)
            repeat {
                z += 0.5
                createPin(x:x,z:z)
            } while z <= 2
            z = 0
        } while x <= 2
    }
    
    func createPin(x:Float, z:Float){
        if let e = try? Entity.loadModel(named: "Bowling_Pin") {
            let size = e.visualBounds(relativeTo: e).extents
            let boxShape = ShapeResource.generateBox(size: size)
            e.collision = CollisionComponent(shapes: [boxShape])
            let kinematics: PhysicsBodyComponent = .init(massProperties: .default,material: nil, mode: .dynamic)
            e.components.set(kinematics)
            e.transform.translation.x = x
            e.transform.translation.z = z
            e.transform.translation.y = e.transform.translation.y + 0.2
            e.name = "pin"
            e.setParent(floorAnchor)
            print("Added pin")
        }
    }
    
    func createView(uiView: ARView) {
        
        print("Create View")
        
        // Create a floor plane
        let planeMeshFloor = MeshResource.generatePlane(width: 25, depth: 25)
        let material = SimpleMaterial(color: .init(red: 0.8, green: 0, blue: 0, alpha: 0), isMetallic: false)
        let planeEntity = ModelEntity(mesh: planeMeshFloor, materials: [material])
        planeEntity.position = tableAnchor.position
        let planePhysicsMaterial = PhysicsMaterialResource.generate(friction: 0.55, restitution: 0.15)
        planeEntity.physicsBody = PhysicsBodyComponent(massProperties: .default, material: planePhysicsMaterial, mode: .static)
        planeEntity.collision = CollisionComponent(shapes: [.generateBox(width: 25, height: 0.1, depth: 25)])
        planeEntity.position = tableAnchor.position
        planeEntity.name = "floor"
        planeEntity.setParent(floorAnchor)
        
        // Create a table plane
        let planeMesh = MeshResource.generatePlane(width: 0.5, depth: 0.5)
        let material2 = SimpleMaterial(color: .init(white: 1.0, alpha: 0), isMetallic: false)
        let planeEntity2 = ModelEntity(mesh: planeMesh, materials: [material2])
        planeEntity2.position = tableAnchor.position
        planeEntity2.physicsBody = PhysicsBodyComponent(massProperties: .default, material: nil, mode: .static)
        planeEntity2.collision = CollisionComponent(shapes: [.generateBox(width: 0.5, height: 0.001, depth: 0.5)])
        planeEntity2.position = tableAnchor.position
        planeEntity2.name = "table"
        planeEntity2.setParent(tableAnchor)
        
        uiView.scene.addAnchor(tableAnchor)
        uiView.scene.addAnchor(floorAnchor)
    }
}
