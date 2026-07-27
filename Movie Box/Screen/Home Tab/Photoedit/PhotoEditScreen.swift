//
//  PhotoEditScreen.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 27/07/26.
//

import SwiftUI

struct PhotoEditScreen: View {
    var body: some View {
        ZStack {
            VStack {
                
                DefaultDesign.Header(name: "Photo Editor")
                
                Spacer()
            }
        }
        .defaultPage()
    }
}

#Preview {
    PhotoEditScreen()
}
