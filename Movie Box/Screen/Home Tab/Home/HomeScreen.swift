//
//  HomeScreen.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 24/07/26.
//

import SwiftUI
import Kingfisher
internal import Combine

struct HomeScreen: View {
    @StateObject var viewModel = HomeViewModel()
    
    
    var body: some View {
        ZStack {
            VStack {
                HomeDesign.Header()
                
                ScrollView(showsIndicators: false) {
                    VStack {
                        HomeDesign.PagerView(viewModel: viewModel)
                        
                        HomeDesign.QuickDiscover(viewModel: viewModel)
                        
                        if let array = viewModel.celebrity?.results {
                            DefaultDesign.SectionHeader(name: "Spotlight Artist") {
                                Router.shared.push(.artist(artistDetail: viewModel.celebrity))
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 24)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(array.indices, id: \.self) { index in
                                        let person = array[index]
                                        DefaultDesign.PersonPoster(url: person.profilePath ?? "", name: person.name)
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                        
                        if let bunch = viewModel.moviesBunch {
                            DefaultDesign.MoviesBunch(moviedbunch: bunch, onViewMore: { media in
                                Router.shared.push(.movieList(movieBunch: bunch))
                            })
                            .padding(.top, 24)
                        }
                    }
                    .padding(.bottom, 80)
                }
            }
        }
        .defaultPage(false)
    }
}

#Preview {
    HomeScreen()
}

class HomeDesign {
    struct Header: View {
        var body: some View {
            HStack {
                VStack(alignment: .leading) {
                    Text("Welcome back,")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.grayColour)
                    
                    Text(appName)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.whiteColour)
                }
                
                Spacer()
                
                Button {
                    print("Search Clicked")
                } label: {
                    Image("ic_search")
                        .resizable()
                        .frame(width: 44, height: 44)
                }
            }
            .padding(.horizontal, 16)

        }
    }
    
    struct PagerView: View {
        @StateObject var viewModel: HomeViewModel
        @State var scrollPosition: Int? = 0
        @State var selectedIndex: Int = 0
        
        var cardWidth: CGFloat { screenWidth * 0.4 }
        var spacing: CGFloat = 18
        
        // Auto-scroll timer
        let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
        
        var body: some View {
            ScrollView(.horizontal) {
                LazyHStack(spacing: spacing) {
                    ForEach(viewModel.topRatedMovie.indices, id: \.self) { index in
                        let movie = viewModel.topRatedMovie[index]
                        let isSelected = isSelected(index)
                        
                        VStack(alignment: .leading, spacing: 0) {
                            ZStack {
                                DefaultDesign.ImageView(url: imageUrl + (movie.posterPath ?? ""), width: cardWidth, height: 220)
                            }
                            .frame(width: cardWidth, height: 220, alignment: .center)
                            .background(.whiteColour)
                            .cornerRadius(20)
                            .overlay {
                                RoundedRectangle(cornerRadius: 20)
                                    .strokeBorder(
                                        LinearGradient( colors: [isSelected ? .skyBlue : .clear, isSelected ? .greenColour : .clear],startPoint: .topLeading, endPoint: .bottomTrailing),
                                        lineWidth: 3
                                    )
                            }
                            .offset(y: isSelected ? -12 : 0)
                            .scaleEffect(isSelected ? 1.02 : 1.0)
                            .shadow(color: isSelected ? .black.opacity(0.2) : .clear, radius: 10, x: 0, y: 8)
                            
                            if isSelected {
                                VStack(alignment: .leading) {
                                    Text(movie.title)
                                        .foregroundColor(.whiteColour)
                                        .font(.system(size: 14, weight: .medium))
                                        .lineLimit(1)
                                    
                                    Text(movie.releaseDate)
                                        .foregroundColor(.grayColour)
                                        .font(.system(size: 12, weight: .regular))
                                        .lineLimit(1)
                                }
                                .transition(
                                    .asymmetric(
                                        insertion: .move(edge: .bottom).combined(with: .opacity),
                                        removal: .opacity
                                    )
                                )
                            }
                        }
                        .frame(width: cardWidth)
                        .animation(.spring(response: 0.38, dampingFraction: 0.72), value: isSelected)
                        .onTapGesture {
                            print(movie.title)
                        }
                    }
                }
                .scrollTargetLayout()
            }
            .safeAreaPadding(.horizontal, (screenWidth - cardWidth) / 2)
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $scrollPosition)
            .onChange(of: scrollPosition) { _, newValue in
                if let newValue {
                    selectedIndex = newValue
                }
            }
            .frame(height: 300)
            .onAppear() {
                DispatchQueue.main.async {
                    self.selectedIndex = 250
                    self.scrollPosition = 250
                }
            }
            .onReceive(timer) { _ in
                self.autoScrollToNext()
            }
        }
        
        private func isSelected(_ index: Int) -> Bool {
            (scrollPosition ?? 0) == index
        }
        
        private func autoScrollToNext() {
            guard !viewModel.topRatedMovie.isEmpty else { return }
            let current = scrollPosition ?? 0
            let next = current < viewModel.topRatedMovie.count - 1 ? current + 1 : 0
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75, blendDuration: 0.3)) {
                scrollPosition = next
            }
        }
    }
    
    struct QuickDiscover: View {
        @StateObject var viewModel: HomeViewModel
        let columns = [
            GridItem(.flexible(), spacing: 10),
            GridItem(.flexible(), spacing: 10)
        ]
        
        var body: some View {
            VStack {
                HStack {
                    Text("Quick Discover")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.whiteColour)
                    
                    Spacer()
                }
                
                
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(viewModel.discover.indices, id: \.self) { index in
                        let discover = viewModel.discover[index]
                        HStack {
                            VStack(alignment: .leading) {
                                Image(discover.image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 48, height: 48, alignment: .center)
                                
                                Text(discover.name)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.whiteColour)
                                
                                Text(discover.info)
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(.grayColour)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(.backgroundColour)
                        .cornerRadius(24)
                        .overlay {
                            RoundedRectangle(cornerRadius: 24)
                                .strokeBorder(.whiteColour.opacity(0.1))
                        }
                    }
                }
            }
            .padding(.horizontal, 16)

        }
    }
    
    
}
