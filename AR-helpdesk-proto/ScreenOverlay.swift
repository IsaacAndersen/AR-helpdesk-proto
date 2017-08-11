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

class ScreenOverlay: SCNNode {
    var screenNode: SCNNode = SCNNode()
    var boxNode: SCNNode = SCNNode()
    
    override init() {
        super.init();
        
        let box = SCNBox(width: 0, height: 0, length: 0, chamferRadius: 0)
        box.firstMaterial?.diffuse.contents = UIColor.red
        boxNode.geometry = box
        boxNode.scale = SCNVector3Make(0.05, 0.05, 0.05)
        boxNode.pivot = SCNMatrix4MakeTranslation(0.5,0.5,0)
        boxNode.rotation = SCNVector4Make(0, 0, 0,0);
        
        let screenPlane = SCNPlane(width: 16, height: 9)
        screenPlane.firstMaterial?.diffuse.contents = UIColor.yellow.cgColor.copy(alpha: 0.15)
        let screenNode = SCNNode(geometry: screenPlane)
        
        // Todo: Scale based on square size.
        screenNode.scale = SCNVector3Make(0.725, 0.725, 0.725)
        screenNode.pivot = SCNMatrix4MakeTranslation(-8, -4.5, 0)
        //screenNode.eulerAngles = SCNVector3Make(-Float.pi/2, 0, 0)
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
        }
        
    }
    
    func addItem() {
        let newGeo = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        newGeo.firstMaterial?.diffuse.contents = UIColor.blue
        let newNode = SCNNode(geometry: newGeo)
        
        let xRand = Float(Float(arc4random()) / Float(UINT32_MAX))*16*0.725
        let yRand = Float(Float(arc4random()) / Float(UINT32_MAX))*9*0.725

        newNode.position = SCNVector3Make(xRand, yRand, 0)
        
        boxNode.addChildNode(newNode);
    }
    
    
    
    
}
