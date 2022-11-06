//
//  HeaderView.swift
//  App
//
//  Created by x on 5/11/2022.
//

import SwiftUI

struct HeaderView: View {
    let title:String
    let subTitle:String
    let titleImage:String

    var body: some View {
        // Title
        HStack{
            Image(systemName: titleImage)
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text(title)
                .font(.title)
                .bold()
        }
        // Subtitle
        Text(subTitle)
            .font(.footnote)
            .multilineTextAlignment(.center)
            .foregroundColor(.secondary)
    }
}
