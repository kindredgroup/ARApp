import SwiftUI
import RealityKit
import Combine

struct ARViewContainer: UIViewRepresentable {
    
    @ObservedObject var selectedObject: SelectedObject
    var a: ARView = ARView(frame: .zero)

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
        //a.debugOptions = [.showAnchorOrigins, .showPhysics]
        a.environment.sceneUnderstanding.options = [
            .occlusion,
            .physics,
            .receivesLighting
        ]
        a.debugOptions.insert(.showSceneUnderstanding)
        a.renderOptions = [.disablePersonOcclusion, .disableDepthOfField, .disableMotionBlur]
        
        createView(arView:a)

        return a
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        context.coordinator.view = uiView
        context.coordinator.selectedObject = selectedObject.name
        
        let longPressGesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleLongPress(_:)))
        uiView.addGestureRecognizer(longPressGesture)
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        uiView.addGestureRecognizer(tapGesture)
    }

    
    func createView(arView: ARView) {
        print("Create View")
    }
}
