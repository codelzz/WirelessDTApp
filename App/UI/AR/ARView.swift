//
//  SceneViewX.swift
//  App
//
//  Created by x on 24/11/2022.
//

import SwiftUI
import SceneKit
import ARKit

struct ARView: UIViewRepresentable {
    func makeUIView(context: Context) -> some UIView {
        let sceneView = ARSCNView() /// Augmented Reality Scene Kit View
        sceneView.showsStatistics = true
        
        let scene = SCNScene(named: "iBeacon.scn")!
        sceneView.scene = scene
        
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
        return sceneView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

struct ARViewSUI: View {
    var body: some View {
        ARView()
    }
}
