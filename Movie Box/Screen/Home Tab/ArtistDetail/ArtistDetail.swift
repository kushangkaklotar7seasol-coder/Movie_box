//
//  ArtistDetail.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 25/07/26.
//

import SwiftUI

struct ArtistDetail: View {
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ZStack {
                    
                    VStack {
                        Spacer()
                        
                        ZStack { }
                        .frame(width: screenWidth, height: 25)
                        .background(.blackColour)
                        .clipShape(
                            UnevenRoundedRectangle(
                                topLeadingRadius: 25,
                                bottomLeadingRadius: 0,
                                bottomTrailingRadius: 0,
                                topTrailingRadius: 25,
                                style: .continuous
                            )
                        )
                    }
                }
                .frame(width: screenWidth, height: 300)
                .background()
                
                VStack() {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Julia Nolan")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.whiteColour)
                            
                            Text("Actor")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.grayColour)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    
                    VStack(spacing: 12) {
                        HStack {
                            Text("Biography")
                                .font(.system(size: 18, weight: .semibold))
                            
                            Spacer()
                        }
                        
                        MovieDetailDesign.ExpandableText(text: "For a struct with all Hashable-conforming properties (String, Int, Bool, Double, arrays/optionals of those, etc.), the compiler auto-synthesizes Hashable for you — you don't need to implement hash(into:) yourself. Just add Hashable to the declaration and it usually just works.")
                    }
                    .padding(.top, 16)
                    .padding(.horizontal, 16)
                    
                    VStack(spacing: 12) {
                        HStack {
                            Text("Personal info")
                                .font(.system(size: 18, weight: .semibold))
                            
                            Spacer()
                        }
                        
                        VStack {
                            Text("Birthday")
                                .foregroundColor(.grayColour)
                            
                            Text("14 Oct, 1998")
                                .foregroundColor(.whiteColour)
                        }
                    }
                    .padding(.top, 16)
                    .padding(.horizontal, 16)
                    
                }
                
                Spacer()
            }
        }
        .defaultPage()
    }
}

#Preview {
    ArtistDetail()
}

class MovieDetailDesign {
    struct ExpandableText: View {
        let text: String

        @State private var isExpanded = false
        @State private var isTruncated = false

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {

                Text(text)
                    .foregroundColor(.grayColour)
                    .lineLimit(isExpanded ? nil : 3)
                    .background(
                        Text(text)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .hidden()
                            .background(
                                GeometryReader { fullGeometry in
                                    Color.clear.onAppear {
                                        let fullHeight = fullGeometry.size.height

                                        DispatchQueue.main.async {
                                            let lineHeight = UIFont.systemFont(ofSize: 17).lineHeight
                                            isTruncated = fullHeight > lineHeight * 3.2
                                        }
                                    }
                                }
                            )
                    )

                if isTruncated {
                    Button(isExpanded ? "Show less..." : "Show more...") {
                        withAnimation {
                            isExpanded.toggle()
                        }
                    }
                }
            }
        }
    }
}
