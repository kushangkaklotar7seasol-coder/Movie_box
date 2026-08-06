//
//  SplashScreen.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 24/07/26.
//

import SwiftUI
import Kingfisher

struct SplashScreen: View {
    @StateObject var viewModel = SplashViewModel()
    
    var body: some View {
        ZStack {
            Text("Splash Screen")
                .font(.system(size: 22, weight: .semibold))
        }
        .defaultPage()
    }
}

#Preview {
    SplashScreen(viewModel: SplashViewModel())
}

class DefaultDesign {
    
    struct SimpleButton: View {
        var name: String
        var onClick: (() -> Void)?
        
        var body: some View {
            Button {
                self.onClick?()
            } label: {
                Text(name)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .foregroundColor(.whiteColour)
                    .font(.system(size: 14, weight: .semibold))
                    .background(
                        LinearGradient(colors: [.skyBlue, .greenColour], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .cornerRadius(30)
            }
        }
    }
    
    struct FullScreenButton: View {
        var name: String
        var onClick: (() -> Void)?
        
        var body: some View {
            Button {
                self.onClick?()
            } label: {
                Text(name)
                    .frame(height: 54)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.whiteColour)
                    .font(.system(size: 18, weight: .semibold))
                    .background(
                        LinearGradient(colors: [.cyanColour, .greenColour], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .cornerRadius(14)
            }
        }
    }
    
    struct ImageView: View {

        let url: String
        var width: CGFloat? = nil
        var height: CGFloat
        var cornerRadius: CGFloat = 0
        var placeholderHeight: CGFloat = 0
        var placeholderImage: String? = nil

        @State private var isFailed: Bool = false

        var body: some View {

            ZStack {

                if isFailed {
                    if let image = placeholderImage {
                        let placeHeight = placeholderHeight == 0 ? height : placeholderHeight
                        Image(image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: placeHeight, height: placeHeight)
                            .frame(width: width, height: height)
                            .frame(maxWidth: width == nil ? .infinity : nil)
                            .background(.grayColour.opacity(0.5))
                    } else {
                        Color.white.opacity(0.3)
                    }
                } else {
                    KFImage(URL(string: url))
                        .onFailure { _ in
                            isFailed = true
                        }
                        .placeholder {
                            ZStack {
                                Color(.grayColour.opacity(0.5))
                                ProgressView()
                            }
                        }
                        .fade(duration: 0.25)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
            }
            .frame(width: width, height: height)
            .frame(maxWidth: width == nil ? .infinity : nil)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
    }
    
    struct SectionHeader: View {
        var name: String = ""
        var buttonName: String = Strings.seeAll
        var onClick: (()->Void)?
        
        var body: some View {
            HStack {
                Text(name.localized())
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.whiteColour)
                
                Spacer()
                
                Button {
                    self.onClick?()
                } label: {
                    Text(buttonName.lowercased())
                        .foregroundColor(.greenColour)
                        .font(.system(size: 13, weight: .semibold))
                }
            }
        }
    }
    
    struct PersonPoster: View {
        var url: String = ""
        var name: String = ""
        
        var width: CGFloat {
            return 100
        }
        
        var body: some View {
            VStack(spacing: 8) {
                ZStack {
                    ZStack {
                        DefaultDesign.ImageView(url: imageUrl+url, width: width-10, height: width-10, placeholderImage: "ic_noImage")
                    }
                    .frame(maxWidth: width, maxHeight: width)
                    .background(.whiteColour)
                    .cornerRadius((width-10)/2 )
                    .padding()
                }
                .frame(width: width, height: width, alignment: .center)
                .background(.clear)
                .cornerRadius(width/2)
                .overlay {
                    RoundedRectangle(cornerRadius: width/2)
                        .fill(.clear)
                        .strokeBorder(.whiteColour.opacity(0.2))
                }
                
                Text(name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.whiteColour)
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
            }
            .frame(width: width)
        }
    }
    
    struct MovieCard: View {
        var movies: MediaItem
        var isShowLike = true
        var onLike: ((MediaItem) -> Void)?
        @State var isLiked: Bool = false
        
        var width: CGFloat {
            return (screenWidth-40)/2.2
        }
        
        var height: CGFloat {
            return width*1.3
        }
        
        var body: some View {
            VStack(alignment: .leading) {
                
                ZStack {
                    DefaultDesign.ImageView(url: imageUrl+(movies.posterPath ?? ""), width: width, height: height)
                    
                    VStack {
                        HStack {
                            ZStack {
                                HStack(spacing: 2) {
                                    Image("ic_star_black")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 10, height: 10, alignment: .center)
                                    
                                    Text("4.5")
                                        .foregroundColor(.blackColour)
                                        .font(.system(size: 10, weight: .medium))
                                }
                                .frame(width: 50, height: 25, alignment: .center)
                                .background(
                                    LinearGradient(colors: [.lightYellowColour, .yellowColour], startPoint: .top, endPoint: .bottom)
                                )
                                .clipShape(
                                    UnevenRoundedRectangle(
                                        topLeadingRadius: 0,
                                        bottomLeadingRadius: 0,
                                        bottomTrailingRadius: 24,
                                        topTrailingRadius: 0,
                                        style: .continuous
                                    )
                                )
                            }
                            
                            Spacer()
                        }
                        
                        Spacer()
                        
                        HStack {
                            
                            Spacer()
                            
//                            Button(){
//                                
//                            } label: {
//                                Image()
//                                    .resizable()
//                                    .frame(width: 28, height: 28, alignment: .center)
                                
                                DefaultDesign.SmallButton(image: self.isLiked ? "ic_like_clear" : "ic_unlike_clear", onClick: {
                                    Utility.addHaptics()
                                    if self.isLiked {
                                        database.removeMovie(id: movies.id)
                                    } else {
                                        database.addMovie(movies)
                                    }
                                    
                                    self.isLiked.toggle()
                                    
                                    onLike?(self.movies)
                                })
//                            }
                        }
                        .padding(8)
                    }
                }
                .frame(width: width, height: height, alignment: .center)
                .background(.grayColour)
                .cornerRadius(24)
                
                Text((movies.title ?? movies.name) ?? "")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.whiteColour)
                    .lineLimit(1)
                
                if let releaseDate = (movies.releaseDate ?? movies.firstAirDate) {
                    Text(releaseDate)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.grayColour)
                        .lineLimit(1)
                }
            }
            .frame(width: width, alignment: .center)
            .onTapGesture {
                Router.shared.push(.movieDetail(movieId: movies.id, isMovie: movies.title != nil ? true : false))
//                movieDetail
            }
            .onAppear() {
                self.isLiked = database.isMovieLiked(id: movies.id)
            }
        }
    }
    
    struct MoviesBunch: View {
        let moviedbunch: MediaBunch
        var onViewMore: ((MediaBunch)->Void)?
        var onMedia: ((MediaItem)->Void)?
        
        var body: some View {
            VStack {
                DefaultDesign.SectionHeader(name: moviedbunch.name) {
                    self.onViewMore?(moviedbunch)
                }
                .padding(.horizontal, 16)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(moviedbunch.media.results.indices, id: \.self) { index in
                            let movie = moviedbunch.media.results[index]
                            MovieCard(movies: movie)
                                .onTapGesture {
                                    self.onMedia?(movie)
                                }
                        }
                    }
                    .padding(.horizontal, 16)
//                    .background()
                }
            }
        }
    }
    
    struct Header: View {
        var name: String = ""
        
        var body: some View {
            HStack {
                
                Button {
                    Router.shared.pop()
                } label: {
                    Image("ic_back")
                        .resizable()
                        .frame(width: 44, height: 44, alignment: .center)
                }
                
                Spacer()
                
                Text(name)
                    .font(.system(size: 18, weight: .semibold))
                
                Spacer()
                
                Image("")
                    .resizable()
                    .frame(width: 44, height: 44, alignment: .center)
            }
        }
    }
    
    struct SmallButton: View {
        var image: String
        var onClick: (()->Void)?
        
        var body: some View {
            Button {
                self.onClick?()
            } label: {
                Image(image)
                    .resizable()
                    .frame(width: 24, height: 24, alignment: .center)
                    .padding(10)
                    .background(.whiteColour.opacity(0.1))
                    .cornerRadius(22)
                    .overlay {
                        RoundedRectangle(cornerRadius: 22)
                            .strokeBorder(.whiteColour.opacity(0.2), lineWidth: 1)
                    }
            }

        }
    }
}
