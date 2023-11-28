import SwiftUI
import RealityKit
import Combine

struct ARViewContainer: UIViewRepresentable {
    
    @ObservedObject var selectedObject: SelectedObject
    @State var objects = [Objects]()
    var a: ARView = ARView(frame: .zero)
    let tableAnchor = AnchorEntity(.plane(.horizontal, classification: .table, minimumBounds: [0.5, 0.5]))
    let floorAnchor = AnchorEntity(.plane(.horizontal, classification: .floor, minimumBounds: [0.5, 0.5]))
    
    func makeCoordinator() -> Coordinator {
        let c: Coordinator = Coordinator()
        c.collisionBeganObserver = a.scene.subscribe(
          to: CollisionEvents.Began.self
        ) { event in
                //print("collision started")
                //print(event.entityA.name)
                //print(event.entityB.name)
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
        JsonApi().getObjects { (objects) in
            self.objects = objects
            print(objects)
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
        
        objects.forEach { c in
            createPin(x:c.x * 5,y:c.y,z:c.z)
        }
    }
    
    func createPin(x:Float, y:Float, z:Float){
        let anchorEntity = AnchorEntity(world: [x,y,z])
        let mesh = MeshResource.generateSphere(radius: 0.2)
        let material = SimpleMaterial(color: .red, isMetallic: true)
        let shape = ShapeResource.generateSphere(radius: 0.2)
        let spherePhysicsMaterial = PhysicsMaterialResource.generate(friction: 0.055, restitution: 0.85)
        let sphere = ModelEntity(mesh: mesh, materials: [material], collisionShape:shape, mass: 0.5)
        let kinematics: PhysicsBodyComponent = .init(massProperties: .default, material: spherePhysicsMaterial, mode: .static)
        sphere.components.set(kinematics)
        sphere.name="ball"
        sphere.setParent(anchorEntity)
        a.scene.addAnchor(anchorEntity)
        print("Added sphere")
        
        if let b = try? Pin.loadBox() {
            b.name = "pin"
            b.setParent(anchorEntity)
            a.scene.addAnchor(anchorEntity)
            print("*******")
            print(b.position)
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
