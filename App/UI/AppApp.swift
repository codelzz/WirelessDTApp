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
    let sync = WiTracingSync.shared()
    /// environment object
    @StateObject var predictor = Predictor(algorithm: SmoothSwapTrilateration())
    @State private var selection = 1

    var body: some Scene {
        WindowGroup {
            TabView(selection: $selection){
                NavigationView {
                    TXListView()
                }.tabItem {
                    Image(systemName: "antenna.radiowaves.left.and.right.circle")
                    Text("TX")
                }.tag(0)
                NavigationView {
                    PredictionView()
                }.tabItem {
                    Image(systemName: "target")
                    Text("Prediction")
                }.tag(1)
                NavigationView {
                    SettingsView()
                }.tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }.tag(2)
            }.environmentObject(predictor)
        }
    }
}
