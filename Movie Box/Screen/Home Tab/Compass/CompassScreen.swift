//
//  CompassScreen.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 27/07/26.
//

import SwiftUI

struct CompassScreen: View {
    var body: some View {
        ZStack {
            VStack {
                DefaultDesign.Header(name: "Compass")
                    .padding(.horizontal, 16)
                
                Spacer()
                
                CompassView()
                
                Spacer()
            }
            .padding(.horizontal, 16)
        }
        .defaultPage()
    }
}

#Preview {
    CompassScreen()
}
