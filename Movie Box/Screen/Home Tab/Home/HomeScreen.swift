//
//  HomeScreen.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 24/07/26.
//

import SwiftUI
import Kingfisher
import Combine

struct HomeScreen: View {
    @StateObject var viewModel = HomeViewModel()
    @EnvironmentObject var localization: LocalizationManager
    
    var body: some View {
        ZStack {
            VStack {
                HomeDesign.Header()
                
                ScrollView(showsIndicators: false) {
                    VStack {
                        HomeDesign.PagerView(viewModel: viewModel)
                        
                        HomeDesign.QuickDiscover(viewModel: viewModel)
                            .id(localization.selectedLanguage)
                        
                        if let array = viewModel.celebrity?.results {
                            DefaultDesign.SectionHeader(name: Strings.sportLightArtist) {
                                Router.shared.push(.artist(artistDetail: viewModel.celebrity))
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 24)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(array.indices, id: \.self) { index in
                                        let person = array[index]
                                        DefaultDesign.PersonPoster(url: person.profilePath ?? "", name: person.name)
                                            .onTapGesture {
                                                Router.shared.push(.artistDetail(artistId: person.id))
                                            }
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
                            .id(localization.selectedLanguage)
                        }
                    }
                    .padding(.bottom, 80)
                }
            }
        }
        .defaultPage(false)
        .id(localization.selectedLanguage)
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
                    Text(Strings.welcomeBack)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.grayColour)
                    
                    Text(appName)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.whiteColour)
                }
                
                Spacer()
                
                Button {
                    Router.shared.push(.search)
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
        var cardHeight: CGFloat { cardWidth * 1.2 }
        
        var spacing: CGFloat = 18
        
        // Auto-scroll timer
        let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
        
        var body: some View {
            if !viewModel.topRatedMovie.isEmpty {
                ScrollView(.horizontal) {
                    LazyHStack(spacing: spacing) {
                        ForEach(viewModel.topRatedMovie.indices, id: \.self) { index in
                            let movie = viewModel.topRatedMovie[index]
                            let isSelected = isSelected(index)
                            
                            VStack(alignment: .leading, spacing: 0) {
                                ZStack {
                                    DefaultDesign.ImageView(url: imageUrl + (movie.posterPath ?? ""), width: cardWidth, height: cardHeight)
                                }
                                .frame(width: cardWidth, height: cardHeight, alignment: .center)
                                .shimmer()
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
                                Router.shared.push(.movieDetail(movieId: movie.id, isMovie: true))
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
                .frame(height: cardHeight+80)
                .onAppear() {
                    DispatchQueue.main.async {
                        if scrollPosition == 0 {
                            self.selectedIndex = 250
                            self.scrollPosition = 250
                        }
                    }
                }
                .onReceive(timer) { _ in
                    self.autoScrollToNext()
                }
            } else {
                ZStack { }
                    .frame(width: cardWidth, height: cardHeight, alignment: .center)
                    .shimmer()
                    .cornerRadius(20)
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
//        let columns = [
//            GridItem(.flexible(), spacing: 10),
//            GridItem(.flexible(), spacing: 10)
//        ]
        var columns: [GridItem] {
            let count = Device.isIpad ? 4 : 2
            return Array(repeating: GridItem(.flexible(), spacing: 15), count: count)
        }
        
        var body: some View {
            VStack {
                HStack {
                    Text(Strings.quickDiscover)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.whiteColour)
                    
                    Spacer()
                }
                
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(viewModel.discover.indices, id: \.self) { index in
                        let discover = viewModel.discover[index]
                        HStack {
                            if Device.isIpad {
                                Spacer()
                            }
                            
                            VStack(alignment: Device.isIpad ? .center : .leading) {
                                Image(discover.image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 48, height: 48, alignment: .center)
                                
                                Text(discover.name.localized())
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.whiteColour)
                                    .lineLimit(1)
                                
                                Text(discover.info.localized())
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(.grayColour)
                                    .lineLimit(1)
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
                        .onTapGesture {
                            if discover.id == 0 {
                                Router.shared.push(.compass)
                            } else if discover.id == 1 {
                                Router.shared.push(.photoEdit)
                            } else if discover.id == 2 {
                                Router.shared.push(.photoCleaner)
                            } else if discover.id == 3 {
                                Router.shared.push(.soundMeter)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)

        }
    }
    
    
}
