//
//  CompassScreen.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 27/07/26.
//

import SwiftUI
import _LocationEssentials
import CoreLocation

struct CompassScreen: View {
    var body: some View {
        ZStack {
            VStack {
                DefaultDesign.Header(name: Strings.compass)
                    .padding(.horizontal, 16)
                
                CompassView()
                
                Spacer(minLength: 8)
                
            }
            .padding(.horizontal, 16)
        }
        .defaultPage()
    }
}

#Preview {
    CompassScreen()
}

class CompassDesign {
    
    struct Detail: View {
        let name: String
        let value: String
        
        var body: some View {
            VStack(alignment: .leading) {
                Text(name)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.grayColour)
                
                Text(value)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.whiteColour)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.backgroundColour)
            .cornerRadius(24)
            .overlay {
                RoundedRectangle(cornerRadius: 24)
                    .stroke(.whiteColour.opacity(0.3))
            }

        }
    }
}
