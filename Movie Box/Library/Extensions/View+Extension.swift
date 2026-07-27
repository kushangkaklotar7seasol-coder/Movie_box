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
                    Image("img_background")
                        .resizable()
                        .scaledToFill()
                        .frame(width: screenWidth, height: screenHeight, alignment: .center)
                        .clipped()
                        .edgesIgnoringSafeArea(.all)
                }
            )
            .navigationBarBackButtonHidden(true)
            .foregroundColor(.whiteColour)
            .onAppear() {
                SwipeBackManager.shared.isEnabled = isSwapBack
            }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
