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
    var upperviewPadding: CGFloat = 30
    
    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    var body: some View {
        ZStack {
            VStack {
                ScrollView(.vertical, showsIndicators: false) {
                    ZStack {
                        KFImage(URL(string: imageUrl+"\(viewModel.movieDetail?.backdropPath ?? "")"))
                            .placeholder({ progress in
                                let placeHolderImage = "ic_noImage"
                                Image(placeHolderImage)
                                    .resizable()
                                    .scaledToFill()
                            })
                            .resizable()
                            .scaledToFill()
                            .frame(width: screenWidth, height: screenWidth)
                            .clipped()
                        
                        if isYoutubeEnabled {
                            VStack {
                                Spacer()
                                
                                HStack(alignment: .center) {
                                    DefaultDesign.SmallButton(image: "ic_play_empty", onClick: {
                                        viewModel.isYoutubeVideo = true
                                    })
                                    
                                    Text("Play Trailer")
                                        .font(.system(size: 18, weight: .medium))
                                }
                                .padding(.bottom, upperviewPadding)
                            }
                        }
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
                                Text(Strings.overview)
                                    .font(.system(size: 18, weight: .semibold))
                                    .padding(.horizontal, 16)
                                    .foregroundColor(.whiteColour)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top, 24)
                                
                                MovieDetailDesign.ExpandableText(text: overView)
                                    .padding(.horizontal, 16)
                            }
                            
                            if !viewModel.personalInformation.isEmpty {
                                Text(Strings.movieInfo)
                                    .font(.system(size: 18, weight: .semibold))
                                    .padding(.horizontal, 16)
                                    .foregroundColor(.whiteColour)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top, 24)
                                
                                
                                MovieDetailDesign.PersonalDetailView(personalDetail: viewModel.personalInformation)
                                    .padding(.top, 16)
                            }
                            
                            
                            if let cast = viewModel.movieCredits?.cast, !cast.isEmpty {
                                HStack {
                                    Text(Strings.topCast)
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.whiteColour)
                                    
                                    Spacer()
                                    
                                    Button {
                                        viewModel.isShowAllCast = true
                                    } label: {
                                        Text(Strings.seeAll)
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
                                                    Router.shared.push(.artistDetail(artistId: cast.id))
                                                }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                                .padding(.top, 10)
                            }
                            
                            
                            if let crew = viewModel.movieCredits?.crew, !crew.isEmpty {
                                Text(Strings.crew)
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
                                                Router.shared.push(.artistDetail(artistId: crew.id))
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            
                            if let array = viewModel.movieImage?.posters, !array.isEmpty {
                                
                                HStack {
                                    Text(Strings.posters)
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.whiteColour)
                                    
                                    Spacer()
                                    
                                    Button {
                                        Router.shared.push(.poster(posters: array))
                                    } label: {
                                        Text(Strings.seeAll)
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
                                                        let placeHolderImage = "ic_noImage"
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
                                                Router.shared.push(.posterDetail(movies: viewModel.movieImage?.posters ?? [], index: index))
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                }
                                .padding(.top, 10)
                            }
                            
                            if let video = viewModel.movieVideo?.results, !video.isEmpty {
                                HStack {
                                    Text(Strings.videos)
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.whiteColour)
                                    
                                    Spacer()
                                    
                                    Button {
                                        Router.shared.push(.videoList(video: video))
                                    } label: {
                                        Text(Strings.seeAll)
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
                                                        let placeHolderImage = "ic_noImage"
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
                    .padding(.top, -upperviewPadding)
                    .padding(.bottom, 30)
                    
                    Spacer()
                }
            }
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                
                HStack {
                    DefaultDesign.SmallButton(image: "ic_arrow_left", onClick: {
                        Router.shared.pop()
                    })
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                
                Spacer()
            }
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
        .sheet(isPresented: $viewModel.isShowAllCast) {
            VStack {
             
                HStack {
                    Text("\(viewModel.movieDetail?.title ?? viewModel.movieDetail?.name ?? "")")
                        .font(.system(size: 20, weight: .semibold))
                    
                    Spacer()
                    
                    Button {
                        viewModel.isShowAllCast = false
                    } label: {
                        Image("ic_cancel")
                            .resizable()
                            .frame(width: 30, height: 30, alignment: .center)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                
                if let cast = viewModel.movieCredits?.cast, !cast.isEmpty {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack {
                            LazyVGrid(columns: self.columns, spacing: 10) {
                                ForEach(cast, id: \.id) { cast in
                                    DefaultDesign.PersonPoster(url: imageUrl+"\(cast.profilePath ?? "")", name: cast.name)
                                        .onTapGesture {
                                            viewModel.isShowAllCast = false
                                            Router.shared.push(.artistDetail(artistId: cast.id))
                                        }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
//        .customSheetView($viewModel.isShowPreview,config:
//                            CustomSheetConfig(customSheetCornerRadius: 20,
//                                              customSheetBlueEffect: 20)) {
//            
//            PhotoPreviewSheet(images: viewModel.movieImage?.posters ?? [],
//                              selectedPosterIndex: viewModel.posterIndex)
//        }
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
                        Utility.addHaptics()
                        viewModel.manageLike()
                    } label: {
                        Image(viewModel.isLiked ? "ic_like_clear" : "ic_unlike_clear")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                    
                    Button {
                        Utility.shareText(viewModel.translatedText())
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

struct PhotoPreviewSheet: View {
    @State var scrollPosition: Int? = 0
    @State var selectedIndex: Int = 0
    
    var images: [MovieImage] = []
    var selectedPosterIndex: Int
    
    var body: some View {
        VStack {
            DefaultDesign.Header(name: "")
                .padding(.horizontal, 16)
            
            ZStack {
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 0) {
                        ForEach(images.indices, id: \.self) { index in
                            let item = images[index]
                            KFImage(URL(string: imageUrl+"\(item.filePath)"))
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: screenWidth-50)
                                .clipped()
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
            }
            .frame(maxWidth: screenWidth-50)
            .frame(maxHeight: screenHeight-200)
            .background()
            .cornerRadius(24)
            .padding(20)
            .onAppear() {
                DispatchQueue.main.async {
                    selectedIndex = selectedPosterIndex
                    scrollPosition = selectedPosterIndex
                }
            }
            
            HStack(spacing: 24) {
                if selectedIndex > 0 {
                    DefaultDesign.SmallButton(image: "ic_arrow_left") {
                        if selectedIndex > 0 {
                            selectedIndex -= 1
                            scrollPosition = selectedIndex
                        }
                    }
                } else {
                    Image("ic_arrow_left")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.grayColour.opacity(0.2))
                        .frame(width: 24, height: 24, alignment: .center)
                        .padding(10)
                        .background(.grayColour.opacity(0.1))
                        .cornerRadius(22)
                        .overlay {
                            RoundedRectangle(cornerRadius: 22)
                                .strokeBorder(.grayColour.opacity(0.2), lineWidth: 1)
                        }
                }
                
                if selectedIndex < images.count - 1 {
                    DefaultDesign.SmallButton(image: "ic_arrow_right") {
                        if selectedIndex < images.count - 1 {
                            selectedIndex += 1
                            scrollPosition = selectedIndex
                        }
                    }
                } else {
                    Image("ic_arrow_right")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.grayColour.opacity(0.2))
                        .frame(width: 24, height: 24, alignment: .center)
                        .padding(10)
                        .background(.grayColour.opacity(0.1))
                        .cornerRadius(22)
                        .overlay {
                            RoundedRectangle(cornerRadius: 22)
                                .strokeBorder(.grayColour.opacity(0.2), lineWidth: 1)
                        }
                }
            }
            .padding(.bottom, 24)
        }
        .defaultPage()
    }
}
