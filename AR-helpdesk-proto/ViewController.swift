//
//  ViewController.swift
//  AR-helpdesk-proto
//
//  Created by ANDERSEN, ISAAC L on 8/1/17.
//  Copyright © 2017 IsaacAndersen. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

import Vision

enum ProgramState: String {
    case OverlayPositioning = "Please find the QR code located on top of the DVR"
    case OverlayAlign = "Align the plane with the surface of the DVR."
    case OverlayActive = "Perfect, let's get assembling!"
    case Power = "Please plug the AC power cable to the back of the box."
    case HDMI = "Please plug in the HDMI cable linking the box to the TV."
    case Coax = "Plug in the coaxial cable to get signal."
    case USB = "Insert the access card to the slot behind the panel on the front of the box."
    case Ready = "Now we're ready to power on the box!"
    
    
    // Add more states
    /*
Plug in POWER
Plug in HDMI
Plug in Coaxial
     
     */
    
    mutating func forward() {
        switch self {
        case .OverlayPositioning:
            self = .OverlayAlign
        case .OverlayAlign:
            self = .OverlayActive
        case .OverlayActive:
            self = .Power
        case .Power:
            self = .HDMI
        case .HDMI:
            self = .Coax
        case .Coax:
            self = .USB
        case .USB:
            self = .Ready
        case .Ready:
            self = .OverlayPositioning
        default:
            break
        }
    }
    
    mutating func back() {
        for _ in 1...self.length()-1 {
            self.forward()
        }
    }
    
    func first() -> ProgramState {
        return ProgramState.OverlayPositioning
    }
    
    func last() -> ProgramState {
        return ProgramState.Ready
    }
    
    func length() -> Int {
        return 8
    }
    
    func description() -> String {
        return self.rawValue
    }
}

class ViewController: UIViewController, ARSCNViewDelegate {
    
    //MARK: Properties
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var debugTextView: UITextView!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    
    
    var visionRequests = [VNRequest]()
    let dispatchQueueML = DispatchQueue(label: "com.hw.dispatchqueueml") // A Serial Queue

    var lastObservation: VNRectangleObservation? = nil;
    var qrBox: ScreenOverlay = ScreenOverlay();
    var reposition: BooleanLiteralType = true;
    
    var state: ProgramState = ProgramState.OverlayPositioning
    var stateIndex: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        forwardButton.addTarget(self, action: #selector(ViewController.forwardButtonPress), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(ViewController.backButtonPress), for: .touchUpInside)
        
        debugTextView.text = ""
        
        let qrRequest = VNDetectBarcodesRequest(completionHandler: barcodeCompleteHandler)
        qrRequest.symbologies = [VNBarcodeSymbology.QR]
        
        visionRequests = [qrRequest]
        
        
        qrBox = ScreenOverlay();
        sceneView.scene.rootNode.addChildNode(qrBox)
        
        handleState()
        
        // Start CoreML
        loopCoreMLUpdate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    
    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    // VISION STUFF
    
    func loopCoreMLUpdate() {
        // Continuously run CoreML whenever it's ready. (Preventing 'hiccups' in Frame Rate)
        
        dispatchQueueML.async {
            // 1. Run Update.
            self.updateCoreML()
            // 2. Loop this function.
            self.loopCoreMLUpdate()
        }
        
    }
    
    func updateCoreML() {
        ///////////////////////////
        // Get Camera Image as RGB
        let pixbuff : CVPixelBuffer? = (sceneView.session.currentFrame?.capturedImage)
        if pixbuff == nil { return }
        let ciImage = CIImage(cvPixelBuffer: pixbuff!)
        // Note: Not entirely sure if the ciImage is being interpreted as RGB, but for now it works with the Inception model.
        // Note2: Also uncertain if the pixelBuffer should be rotated before handing off to Vision (VNImageRequestHandler) - regardless, for now, it still works well with the Inception model.

        
        let imageRequestHandler = VNImageRequestHandler(ciImage: ciImage, orientation: CGImagePropertyOrientation.rightMirrored, options: [:])
        
        ///////////////////////////
        // Run Image Request
        do {
            try imageRequestHandler.perform(self.visionRequests)
        } catch {
            print(error)
        }
        
    }
    
    func barcodeCompleteHandler(request: VNRequest, error: Error?) {
        // Catch errors
        if error != nil {
            print("Error: " + (error?.localizedDescription)!)
            return
        }
        guard let observations = request.results as? [VNBarcodeObservation] else {
            return
        }
        
        guard observations.first != nil else {
            DispatchQueue.main.async {
                
            }
            return
        }
        
        DispatchQueue.main.async {
            // Print Classifications
            self.addQRMarker(observations)
        }
    }
    
    func rectangleCompleteHandler(request: VNRequest, error: Error?) {
        // Catch errors
        if error != nil {
            print("Error: " + (error?.localizedDescription)!)
            return
        }
        guard let observations = request.results as? [VNRectangleObservation] else {
            print("Wrong result type.")
            return
        }
        
        // Question: Any ordering w/ rectangles? Size?
        guard observations.first != nil else {
            DispatchQueue.main.async {
                self.imageView.image = nil
            }
            return
        }
        
        DispatchQueue.main.async {
            // Print Classifications
            self.drawVisionRequestResults(observations)
        }
    }
    
    func addQRMarker(_ observations:[VNBarcodeObservation]) {
        guard let observation = observations.first else {return}
        
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        let scale = { (o: CGPoint) -> CGPoint in
            return CGPoint(x: (o.x-0)*screenWidth, y:(o.y-0)*screenHeight)
        }
        
        let results = sceneView.hitTest(scale(observation.bottomLeft), types: [ARHitTestResult.ResultType.featurePoint]);
        guard let hitFeature = results.last else {return}
        
        let hitTransform = SCNMatrix4(hitFeature.worldTransform)
        let hitPosition = SCNVector3Make(hitTransform.m41,
                                         hitTransform.m42,
                                         hitTransform.m43)
        
        
        if (reposition) {
            qrBox.position = hitPosition
            reposition = false;
        }
        
    }
    
    @objc func drawVisionRequestResults(_ results:[VNRectangleObservation]) {
        UIGraphicsBeginImageContext(imageView.frame.size);
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        for result in results {
            
            //2
            print(String(result.bottomLeft.debugDescription));
            
            let screenSize = UIScreen.main.bounds
            let screenWidth = screenSize.width
            let screenHeight = screenSize.height
            
            let scale = { (o: CGPoint) -> CGPoint in
                return CGPoint(x: (o.x-0)*screenWidth, y:(o.y-0)*screenHeight)
            }
            
            print(String(scale(result.bottomLeft).debugDescription));
            
            ctx.beginPath()
            ctx.move(to: scale(result.bottomLeft))
            ctx.addLine(to: scale(result.bottomRight))
            ctx.addLine(to: scale(result.topRight))
            ctx.addLine(to: scale(result.topLeft))
            ctx.addLine(to: scale(result.bottomLeft))
            ctx.setLineWidth(5)
            
            //3
            ctx.closePath()
            ctx.setStrokeColor(UIColor.red.cgColor)
            ctx.strokePath()
            
            imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        switch (state) {
        case .OverlayPositioning:
            reposition = true
            qrBox.setAligning(state: false)
        case .OverlayAlign:
            if (qrBox.constraints?.count == 0) {
                qrBox.setAligning(state: false)
            } else {
                qrBox.setAligning(state: true)
            }
        default:
            break
        }
    }
    
    func setText(string: String) {
        self.debugTextView.text = "\(state.description())\n"
    }
    
    @objc func backButtonPress() {
        if (self.state != self.state.first()) {
            self.state.back();
            stateIndex -= 1
        }
        handleState()
        
    }
    
    @objc func forwardButtonPress() {
        if (self.state != self.state.last()) {
            self.state.forward();
            stateIndex += 1
        }
        handleState()
    }
    
    func handleState() {
        setText(string: "")
        self.progressBar.setProgress(Float(stateIndex)/Float(state.length()), animated: true)
        if (state == .OverlayAlign) {
            qrBox.setAligning(state: true)
        } else {
            qrBox.setAligning(state: false)
        }
        
        switch (state) {
        case .OverlayPositioning:
            break
        case .OverlayAlign:
            break
        case .OverlayActive:
            qrBox.togglePort(port: Port.PowerCable, set: true)
        case .Power:
            qrBox.togglePort(port: Port.HDMI, set: true)
            qrBox.togglePort(port: Port.PowerCable, set: false)
        case .HDMI:
            qrBox.togglePort(port: Port.HDMI, set: false)
            qrBox.togglePort(port: Port.Coaxial, set: true)
            qrBox.togglePort(port: Port.PowerCable, set: true)
            break;
        case .Coax:
            qrBox.togglePort(port: Port.HDMI, set: true)
            qrBox.togglePort(port: Port.Coaxial, set: false)
            qrBox.togglePort(port: Port.USB, set: true)
            break
        case .USB:
            qrBox.togglePort(port: Port.Coaxial, set: true)
            qrBox.togglePort(port: Port.USB, set: false)
            qrBox.togglePort(port: Port.Button, set: true)
            break
        case .Ready:
            qrBox.togglePort(port: Port.USB, set: true)
            qrBox.togglePort(port: Port.Button, set: false)
            break
        }
    }
}
