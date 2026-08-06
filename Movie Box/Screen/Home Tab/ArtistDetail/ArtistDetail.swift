//
//  ArtistDetail.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 25/07/26.
//

import SwiftUI
import Kingfisher

struct ArtistDetail: View {
    @StateObject var viewModel: ArtistDetailViewModel
    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                                
                MovieDetailDesign.TopView(viewModel: viewModel)
                
                ScrollView(showsIndicators: false) {
                    VStack() {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(viewModel.celebrityDetail?.name ?? "")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.whiteColour)
                                    .lineLimit(1)
                                
                                Text(viewModel.celebrityDetail?.knownForDepartment ?? "")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.grayColour)
                                    .lineLimit(1)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        
                        if viewModel.celebrityDetail?.biography != "" {
                            VStack(spacing: 12) {
                                HStack {
                                    Text(Strings.biography)
                                        .font(.system(size: 18, weight: .semibold))
                                    
                                    Spacer()
                                }
                                
                                MovieDetailDesign.ExpandableText(text: viewModel.celebrityDetail?.biography ?? "")
                            }
                            .padding(.top, 16)
                            .padding(.horizontal, 16)
                        }
                        
                        if !viewModel.personalDetail.isEmpty {
                            HStack {
                                Text(Strings.personalInfo)
                                    .font(.system(size: 18, weight: .semibold))
                                
                                Spacer()
                            }
                            .padding(.top, 16)
                            .padding(.horizontal, 16)
                            
                            MovieDetailDesign.PersonalDetailView(personalDetail: viewModel.personalDetail)
                        }
                        
                        if let movies = viewModel.movieCredits?.cast{
                            DefaultDesign.SectionHeader(name: Strings.movie, onClick: {
                                viewModel.type = 0
                                viewModel.isViewAllSheet = true
                            })
                            .padding(.horizontal, 16)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(movies.indices, id: \.self) { index in
                                        let movie = movies[index]
                                        DefaultDesign.MovieCard(movies: movie)
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                        
                        if let series = viewModel.seriesCredits?.cast{
                            DefaultDesign.SectionHeader(name: Strings.tvShow, onClick: {
                                viewModel.type = 1
                                viewModel.isViewAllSheet = true
                            })
                            .padding(.horizontal, 16)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(series.indices, id: \.self) { index in
                                        let movie = series[index]
                                        DefaultDesign.MovieCard(movies: movie)
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                }
                
                
            }
        }
        .defaultPage()
        .sheet(isPresented: $viewModel.isViewAllSheet) {
            VStack {
                HStack {
                    Button {
                        viewModel.isViewAllSheet = false
                    } label: {
                        Image("ic_cancel")
                            .resizable()
                            .frame(width: 30, height: 30, alignment: .center)
                    }
                    
                    Text("\(viewModel.celebrityDetail?.name ?? "")")
                        .font(.system(size: 21, weight: .semibold))
                        .lineLimit(1)
                    
                    Spacer()
                }
                .padding(.vertical, 5)
                .padding(.horizontal, 16)
                
                if let series = viewModel.type == 0 ? viewModel.movieCredits?.cast : viewModel.seriesCredits?.cast {
                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: self.columns, spacing: 10) {
                            ForEach(series.indices, id: \.self) { index in
                                let movie = series[index]
                                DefaultDesign.MovieCard(movies: movie)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
            }
        }
    }
}

#Preview {
    ArtistDetail(viewModel: ArtistDetailViewModel())
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
                    Button(isExpanded ? Strings.showLess : Strings.showMore) {
                        withAnimation {
                            isExpanded.toggle()
                        }
                    }
                }
            }
        }
    }
    
    struct TopView: View {
        @StateObject var viewModel: ArtistDetailViewModel
        
        var body: some View {
            ZStack {
                KFImage(URL(string: imageUrl+(viewModel.celebrityDetail?.profilePath ?? "")))
                    .placeholder({ progress in
                        let placeHolderImage = "ic_noImage"
                        Image(placeHolderImage)
                            .resizable()
                            .scaledToFill()
                    })
                    .resizable()
                    .scaledToFill()
                    .frame(width: screenWidth, height: 400)
                    .clipped()
                    
                VStack {
                    DefaultDesign.Header(name: "")
                        .padding(.top, 100)
                        .padding(.horizontal, 16)
                    
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
            .edgesIgnoringSafeArea(.top)

        }
    }
    
    struct PersonalDetailView: View {
        let columns = [
            GridItem(.flexible(), spacing: 10),
            GridItem(.flexible(), spacing: 10)
        ]
        var personalDetail: [PersonalDetail]
        
        var body: some View {
            VStack(spacing: 12) {
                
                LazyVGrid(columns: self.columns, spacing: 10) {
                    ForEach(personalDetail, id: \.id) { detail in
                        VStack(alignment: .leading) {
                            Text(detail.name)
                                .foregroundColor(.grayColour)
                                .lineLimit(1)
                            
                            Text(detail.value)
                                .foregroundColor(.whiteColour)
                                .lineLimit(1)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.backgroundColour)
                        .cornerRadius(24)
                        .overlay(
                            RoundedRectangle(cornerRadius:24)
                                .strokeBorder(.whiteColour.opacity(0.2))
                        )
                    }
                }
            }
//            .padding(.top, 16)
            .padding(.horizontal, 16)

        }
    }
}
