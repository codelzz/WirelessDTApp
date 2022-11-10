//
//  AppApp.swift
//  App
//
//  Created by x on 3/11/2022.
//

import SwiftUI

@main
struct AppApp: App {
    /// initialize the singleton
    let conf = Config.shared()
    let txmanager = TXManager.shared()
    let sync = WiTracingSync.shared()
    let model = DeepPos()
    /// environment object
    @StateObject var predictor = Predictor(algorithm: SmoothSwapTrilateration())
    @StateObject var dlPredictor = DeepProcessor.shared()
    @State private var selection = 1

    var body: some Scene {
        WindowGroup {
            TabView(selection: $selection){
                NavigationView {
                    TXListView()
                }.tabItem {
                    Image(systemName: Constant.TXIcon)
                    Text(Constant.TX)
                }.tag(0)
                NavigationView {
                    PredictionView()
                }.tabItem {
                    Image(systemName: Constant.PredictionIcon)
                    Text(Constant.Prediction)
                }.tag(1)
                NavigationView {
                    DeepLearningView()
                }.tabItem {
                    Image(systemName: Constant.DeepLearningIcon)
                    Text(Constant.DeepLearning)
                }.tag(2)
            }.environmentObject(predictor)
                .environmentObject(dlPredictor)
        }
    }
}
