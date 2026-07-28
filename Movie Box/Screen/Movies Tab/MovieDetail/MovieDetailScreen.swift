//
//  MovieDetailScreen.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 28/07/26.
//

import SwiftUI
import Kingfisher
import WebKit

struct MovieDetailScreen: View {
    @StateObject var viewModel: MovieDetailViewModel
    
    var body: some View {
        ZStack {
            VStack {
                ScrollView(.vertical, showsIndicators: false) {
                    ZStack {
                        KFImage(URL(string: imageUrl+"\(viewModel.movieDetail?.posterPath ?? "")"))
                            .resizable()
                            .scaledToFill()
                            .frame(width: screenWidth, height: screenWidth)
                            .clipped()
                    }
                    .frame(width: screenWidth, height: screenWidth, alignment: .center)
                    .background()
                    
                    ZStack {
                        
                        VStack(spacing: 0) {
                            MovieDetail.GeneralInfo(viewModel: viewModel)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(viewModel.movieDetail?.genres ?? []) { gener in
                                        Text(gener.name)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 6)
                                            .background(.backgroundColour)
                                            .cornerRadius(20)
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                            if let overView = viewModel.movieDetail?.overview, overView != "" {
                                Text("Overview")
                                    .font(.system(size: 18, weight: .semibold))
                                    .padding(.horizontal, 16)
                                    .foregroundColor(.whiteColour)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top, 24)
                                
                                MovieDetailDesign.ExpandableText(text: overView)
                                    .padding(.horizontal, 16)
                            }
                            
                            if !viewModel.personalInformation.isEmpty {
                                Text("Movie info")
                                    .font(.system(size: 18, weight: .semibold))
                                    .padding(.horizontal, 16)
                                    .foregroundColor(.whiteColour)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top, 24)
                                
                                
                                MovieDetailDesign.PersonalDetailView(personalDetail: viewModel.personalInformation)
                            }
                            
                            
                            if let cast = viewModel.movieCredits?.cast, !cast.isEmpty {
                                HStack {
                                    Text("Top Cast")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.whiteColour)
                                    
                                    Spacer()
                                    
                                    Button {
                                        
                                    } label: {
                                        Text("See All")
                                            .foregroundColor(.greenColour)
                                            .font(.system(size: 13, weight: .semibold))
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 24)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(cast, id: \.id) { cast in
                                            DefaultDesign.PersonPoster(url: imageUrl+"\(cast.profilePath ?? "")", name: cast.name)
                                                .onTapGesture {
                                                    viewModel.selectedCelebrityId = cast.id
                                                    viewModel.isShowCastDetails = true
                                                }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                                .padding(.top, 10)
                            }
                            
                            
                            if let crew = viewModel.movieCredits?.crew, !crew.isEmpty {
                                Text("Crew")
                                    .font(.system(size: 18, weight: .semibold))
                                    .padding(.horizontal, 16)
                                    .foregroundColor(.whiteColour)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top, 24)
                                    .padding(.bottom, 8)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(crew, id: \.id) { crew in
                                            VStack(alignment: .leading) {
                                                Text(crew.department)
                                                    .font(.system(size: 14, weight: .regular))
                                                    .foregroundColor(.grayColour)
                                                
                                                Text(crew.name)
                                                    .lineLimit(2)
                                            }
                                            .padding()
                                            .frame(width: (screenWidth-32)/2.5, alignment: .leading)
                                            .frame(height: 100)
                                            .background(.backgroundColour)
                                            .cornerRadius(14)
                                            .onTapGesture {
                                                viewModel.selectedCelebrityId = crew.id
                                                viewModel.isShowCastDetails = true
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            
                            if let array = viewModel.movieImage?.posters, !array.isEmpty {
                                
                                HStack {
                                    Text("Posters")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.whiteColour)
                                    
                                    Spacer()
                                    
                                    Button {
                                        Router.shared.push(.poster(posters: array))
                                    } label: {
                                        Text("See All")
                                            .foregroundColor(.greenColour)
                                            .font(.system(size: 13, weight: .semibold))
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 24)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(array.indices, id: \.self) { index in
                                            ZStack {
                                                KFImage.url(URL(string: imageUrl+array[index].filePath))
                                                    .placeholder({ progress in
                                                        let placeHolderImage = "img_noimage"
                                                        Image(placeHolderImage)
                                                            .resizable()
                                                            .scaledToFill()
                                                    })
                                                    .resizable()
                                                    .scaledToFill()
                                            }
                                            .frame(width: (screenWidth-32)/2.5, height: (screenWidth-32)/2, alignment: .center)
                                            .background()
                                            .cornerRadius(24)
                                            .onTapGesture {
                                                viewModel.posterIndex = index
                                                viewModel.isShowPosterDetail = true
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                }
                                .padding(.top, 10)
                            }
                            
                            
                            if let video = viewModel.movieVideo?.results, !video.isEmpty {
                                HStack {
                                    Text("Videos")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.whiteColour)
                                    
                                    Spacer()
                                    
                                    Button {
                                        
                                    } label: {
                                        Text("See All")
                                            .foregroundColor(.greenColour)
                                            .font(.system(size: 13, weight: .semibold))
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 24)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(video, id: \.key) { video in
                                            ZStack {
                                                KFImage.url(URL(string: "https://img.youtube.com/vi/\(video.key)/hqdefault.jpg"))
                                                    .placeholder({ progress in
                                                        let placeHolderImage = "img_noimage"
                                                        Image(placeHolderImage)
                                                            .resizable()
                                                            .scaledToFill()
                                                    })
                                                    .resizable()
                                                    .scaledToFill()
                                                
                                                if isYoutubeEnabled {
                                                    Image("ic_play")
                                                        .resizable()
                                                        .frame(width: 30, height: 30, alignment: .center)
                                                }
                                            }
                                            .frame(width: (screenWidth-32)/2, height: (screenWidth-32)/2.5, alignment: .center)
                                            .background()
                                            .cornerRadius(14)
                                            .onTapGesture {
                                                if isYoutubeEnabled {
                                                    viewModel.youtubeUrl = "https://www.youtube.com/watch?v=\(video.key)"
                                                    viewModel.isYoutubeVideo = true
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                                .padding(.top, 10)
                            }
                        }
                    }
                    .background(.blackColour)
                    .cornerRadius(20)
                    .padding(.top, -30)
                    .padding(.bottom, 30)
                    
                    Spacer()
                }
            }
            .edgesIgnoringSafeArea(.all)
        }
        .defaultPage()
        .sheet(isPresented: $viewModel.isYoutubeVideo) {
            NavigationStack {
                WebView(url: URL(string: viewModel.youtubeUrl)!)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") {
                                viewModel.isYoutubeVideo = false
                            }
                        }
                    }
            }
        }
        .sheet(isPresented: $viewModel.isShowPreview) {
            VStack {
                ZStack {
                    
                }
                
                HStack(spacing: 24) {
                    Button {
                        
                    } label: {
                        Image("")
                            .resizable()
                            .frame(width: 44, height: 44, alignment: .center)
                    }
                    
                    Button {
                        
                    } label: {
                        Image("")
                            .resizable()
                            .frame(width: 44, height: 44, alignment: .center)
                    }
                }
            }
            .presentationDetents([.fraction(0.9)])
            .presentationBackground(.backgroundColour)
        }
    }
}

#Preview {
    MovieDetailScreen(viewModel: MovieDetailViewModel())
}

class MovieDetail {
    
    struct GeneralInfo: View {
        @StateObject var viewModel: MovieDetailViewModel
        
        var body: some View {
            VStack(spacing: 2) {
                VStack(alignment: .leading) {
                    Text("\(viewModel.movieDetail?.title ?? viewModel.movieDetail?.name ?? "")")
                        .font(.system(size: 20, weight: .semibold))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    Text(viewModel.movieDetail?.releaseDate ?? viewModel.movieDetail?.firstAirDate ?? "")
                        .font(.system(size: 14, weight: .regular))
                    
                    Circle()
                        .fill(.grayColour)
                        .frame(width: 5, height: 5, alignment: .center)
                    
                    HStack(spacing: 3) {
                        Image("ic_star_yello")
                            .resizable()
                            .frame(width: 16, height: 16)
                        
                        let star = (viewModel.movieDetail?.voteAverage ?? 0.0)/2
                        Text("\(star)".prefix(3))
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.lightYellowColour)
                    }
                    
                    Spacer()
                    
                    Button {
                        
                    } label: {
                        Image("ic_unlike_clear")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                    
                    Button {
                        
                    } label: {
                        Image("ic_share_clear")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .padding(.leading, 14)
                    }
                }
                
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 16)

        }
    }
}
