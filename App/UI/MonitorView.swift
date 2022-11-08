//
//  MonitorView.swift
//  App
//
//  Created by x on 3/11/2022.
//

import SwiftUI

struct MonitorView: View {
    var body: some View {
        VStack {
            // Title
            HStack{
                Image(systemName: "apps.iphone")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                Text("WiTracing App")
                    .font(.title)
                    .bold()
            }
            // Subtitle
            Text("The Demo App for WiTracing Simulation Tool")
                .font(.footnote)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            Spacer()
        }
    }
}
