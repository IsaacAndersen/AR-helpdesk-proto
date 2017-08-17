//
//  ScreenOverlay.swift
//  AR-helpdesk-proto
//
//  Created by ANDERSEN, ISAAC L on 8/7/17.
//  Copyright © 2017 IsaacAndersen. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

enum Port: Int{
    case HDMI
    case Ethernet
    case Coaxial
    case USB
}

class ScreenOverlay: SCNNode {
    var screenNode: SCNNode = SCNNode()
    var boxNode: SCNNode = SCNNode()
    
    var portDict: Dictionary = [String : SCNNode]()
    
    override init() {
        super.init();
        
        let box = SCNBox(width: 0, height: 0, length: 0, chamferRadius: 0)
        box.firstMaterial?.diffuse.contents = UIColor.red
        boxNode.geometry = box
        boxNode.scale = SCNVector3Make(0.05, 0.05, 0.05)
        boxNode.pivot = SCNMatrix4MakeTranslation(0,0,0)
        boxNode.rotation = SCNVector4Make(0, 0, 0,0);
        
        let width: Float = 9.5
        let height: Float = 7.0
        
        
        let screenPlane = SCNPlane(width: CGFloat(width), height: CGFloat(height))
        screenPlane.firstMaterial?.diffuse.contents = UIColor.yellow.cgColor.copy(alpha: 0.25)
        let screenNode = SCNNode(geometry: screenPlane)
        
        // Todo: Scale based on square size.
        screenNode.scale = SCNVector3Make(0.725, 0.725, 0.725)
        screenNode.pivot = SCNMatrix4MakeTranslation(-width/2, -height/2, 0)
        screenNode.eulerAngles = SCNVector3Make(-Float.pi/4, 0, 0)
        boxNode.addChildNode(screenNode)
        self.addChildNode(boxNode)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setAligning(state: Bool) {
        if (state) {
            self.constraints = [SCNBillboardConstraint()]
        } else {
            self.constraints = [];
            boxNode.rotation = self.rotation
        }
        
    }
    
    func addItem() {
        print("Adding item.")
        let newGeo = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        newGeo.firstMaterial?.diffuse.contents = UIColor.blue
        let newNode = SCNNode(geometry: newGeo)
        
        let usbScene = SCNScene(named: "art.scnassets/usb2.scn")
        let usbNode = (usbScene?.rootNode.childNode(withName: "usb01", recursively: true))!
        
        let coaxScene = SCNScene(named: "art.scnassets/coaxialcable.dae")
        let coaxNode = (coaxScene?.rootNode.childNode(withName: "coaxial", recursively: true))!
        
        let hdmiScene = SCNScene(named: "art.scnassets/hdmi.dae")
        let hdmiNode = (hdmiScene?.rootNode.childNode(withName: "hdmi", recursively: true))!
        
        let xRand = Float(Float(arc4random()) / Float(UINT32_MAX))*9.5*0.725
        let yRand = Float(Float(arc4random()) / Float(UINT32_MAX))*7.0*0.725

        usbNode.position = SCNVector3Make(xRand, yRand, 0)
        newNode.position = SCNVector3Make(xRand, yRand, 0)
        hdmiNode.position = SCNVector3Make(xRand, yRand, 0)
        coaxNode.position = SCNVector3Make(xRand, yRand, 0)
        
        boxNode.addChildNode(hdmiNode)
        //screenNode.addChildNode(boxNode);
        print("Count: \(screenNode.childNodes.count)")
    }
    
    
    //MARK: Ports
    
    func togglePort(port: Port) {
        var scnName = ""
        var itemName = ""
        var pos = SCNVector3Zero
        
        switch (port) {
        case .HDMI:
            scnName = "art.scnassets/hdmi.dae"
            itemName = "hdmi"
            pos = SCNVector3Make(0.5*9.5*0.725, 0.5*9.5*0.725, 0)
            break
        case .Coaxial:
            scnName = "art.scnassets/coaxialcable.dae"
            itemName = "coaxial"
            pos = SCNVector3Make(0.5, 0.5, 0.5)
            break
        case .USB:
            scnName = "art.scnassets/usb2.scn"
            itemName = "usb01"
            pos = SCNVector3Make(0.5, 0.5, 0.5)
            break
        default:
            break
        }
        
        guard let currentNode = portDict[itemName] else {
            let itemScene = SCNScene(named: scnName)
            let itemNode = (itemScene?.rootNode.childNode(withName: itemName, recursively: true))!
            itemNode.position = SCNVector3Zero
            itemNode.scale = SCNVector3Make(50, 50, 50)
            boxNode.addChildNode(itemNode)
            portDict[itemName] = itemNode
            return
        }
        
        currentNode.removeFromParentNode()
        portDict[itemName] = nil
    }
    
    
    
    
}
