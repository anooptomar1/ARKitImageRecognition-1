# AR Kit Image Recognition Demo

## Intro 
This repository contains a simple ARkit demo that detects images and places videos and 3D Objects. To create this demo I used and modifed a project made by Jayven N. from AppCoda (https://appcoda.com/arkit-image-recognition/). Check out his post about image recognition since it's the base of this demo. 
Feel free to use this example to create some new awsome apps :) 



## Detect images
To detect images I created 2 markers. All markers should be named and stored in the `AR Resources` folder inside the `Assets.xcassets`, every marker will be associated to a different `SceneKit Node` Object. 

## Create a video Node
To make a video display as a AR object I created a `tvPlaneNode` where I applied a texture.

`````swift
    lazy var videoNode: SCNNode = {
        
        let currentFrame = self.sceneView.session.currentFrame
        
        let videoNode = SKVideoNode(fileNamed: "video.mp4")
        videoNode.play()
        let skScene = SKScene(size: CGSize(width: 1280  , height: 720))
        skScene.addChild(videoNode)
        
        videoNode.position = CGPoint(x: skScene.size.width/2, y: skScene.size.height/2)
        videoNode.size = skScene.size

        let tvPlane = SCNPlane(width: 1.0, height: 0.75)
        tvPlane.firstMaterial?.diffuse.contents = skScene
        tvPlane.firstMaterial?.isDoubleSided = true
        
        let tvPlaneNode = SCNNode(geometry: tvPlane)
        
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -1.0
        
        tvPlaneNode.eulerAngles = SCNVector3(Double.pi,0,0)
 
        let scaleFactor  = 0.2
        tvPlaneNode.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
        tvPlaneNode.eulerAngles.x = GLKMathDegreesToRadians(90)
        return tvPlaneNode
    }()
  `````
  
##  Create a 3D Object 
  

`````swift
      lazy var shipNode: SCNNode = {
        guard let scene = SCNScene(named: "ship.scn"),
            let node = scene.rootNode.childNode(withName: "ship", recursively: false) else { return SCNNode() }
        let scaleFactor  = 0.1
        node.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
        node.eulerAngles.x = GLKMathDegreesToRadians(-90)
        return node
    }()
    
`````


##  Render video and 3D Object 



`````swift
extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            guard let imageAnchor = anchor as? ARImageAnchor,
                let imageName = imageAnchor.referenceImage.name else { return }
            
            if (imageName == "video"){
                let planeNode = self.videoNode
                planeNode.opacity = 0.0
                planeNode.eulerAngles.x = .pi / 2
                planeNode.runAction(self.spinAction)
                node.addChildNode(planeNode)
            }
            
            if(imageName == "ship"){
                let overlayNode = self.shipNode
                overlayNode.opacity = 0
                overlayNode.position.y = 0.2
                overlayNode.runAction(self.spinAction)
                
                node.addChildNode(overlayNode)
            }
        }
    }
    
}
`````
