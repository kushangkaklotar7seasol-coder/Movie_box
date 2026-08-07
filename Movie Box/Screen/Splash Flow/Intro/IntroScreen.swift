//
//  IntroScreen.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 24/07/26.
//

import SwiftUI

struct IntroScreen: View {
    @StateObject var viewModel = IntroViewModel()
    @State var scrollPosition: Int? = 0
    @State var selectedIndex: Int = 0
    
    var body: some View {
        ZStack {
            
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(viewModel.information.indices, id: \.self) { index in
                        let item = viewModel.information[index]
                        
                        Image(item.image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: screenWidth,
                                   height: screenHeight)
                            .clipped()
                            .id(index)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $scrollPosition)
            .ignoresSafeArea()
            .onChange(of: scrollPosition) { _, newValue in
                if let newValue {
                    selectedIndex = newValue
                }
            }
            
            // MARK: Content
            
            VStack {
                
                Spacer()
                
                Text(viewModel.information[selectedIndex].name)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.whiteColour)
                    .padding(.bottom, 10)
                
                Text(viewModel.information[selectedIndex].info)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.grayColour)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 10)
                
                HStack(spacing: 8) {
                    ForEach(viewModel.information.indices, id: \.self) { index in
                        Capsule()
                            .fill(
//                                index == selectedIndex ? .orange : .gray
                                
                                LinearGradient(colors: [index == selectedIndex ? .cyanColour : .grayColour , index == selectedIndex ? .greenColour : .grayColour ], startPoint: .topLeading, endPoint: .bottomTrailing)
                            
                            )
                            .frame(width: index == selectedIndex ? 8 : 8,
                                   height: 8)
                            .animation(.easeInOut, value: selectedIndex)
                    }
                }
                .padding(.bottom, 24)
                
                DefaultDesign.FullScreenButton(name: selectedIndex == viewModel.information.count - 1 ? Strings.getStated : Strings.next) {
                    if selectedIndex < viewModel.information.count - 1 {
                        selectedIndex += 1
                        withAnimation(.easeInOut(duration: 0.35)) {
                            scrollPosition = selectedIndex
                        }
                    } else {
                        UserdefaultManager.shared.saveIntro(0)
                        Router.shared.updateRoot(.tab)
                    }
                }
                .padding(.bottom,40)
            }
            .padding(.horizontal,16)
        }
        .defaultPage(true)
        .background(.blackColour)
    }
}

#Preview {
    IntroScreen()
}
