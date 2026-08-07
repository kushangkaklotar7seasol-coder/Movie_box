//
//  View+Extension.swift
//  Korvani
//
//  Created by Kushang kaklotar on 11/07/26.
//

import Foundation
import SwiftUI

extension View {
    func defaultPage(_ isSwapBack: Bool = true) -> some View {
        self
            .background (
                ZStack {
                    Image("img_background")//Device.isIpad ? Device.isLandscape ? "img_background_ipad_landscape" : "img_background_ipad" :
                        .resizable()
                        .scaledToFill()
                        .frame(width: screenWidth, height: screenHeight, alignment: .center)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                        .edgesIgnoringSafeArea(.all)
                }
            )
            .navigationBarBackButtonHidden(true)
            .foregroundColor(.whiteColour)
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func shimmer() -> some View {
        self
            .background(
                Color.gray.opacity(0.4)
                    .modifier(ShimmerModifier())
            )
    }
}
