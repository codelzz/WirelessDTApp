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
                    SettingsView()
                }.tabItem {
                    Image(systemName: Constant.SettingsIcon)
                    Text(Constant.Settings)
                }.tag(2)
            }.environmentObject(predictor)
        }
    }
}
