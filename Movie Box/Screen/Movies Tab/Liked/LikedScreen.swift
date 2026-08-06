//
//  LikedScreen.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 29/07/26.
//

import SwiftUI

struct LikedScreen: View {
    @StateObject var viewModel = LikedViewModel()
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            VStack {
                DefaultDesign.Header(name: Strings.favourite)
                
                CustomSegmentedControl(preselectedIndex: $viewModel.selectedIndex, options: [Strings.movie, Strings.tvShow])
                
                if viewModel.selectedIndex == 0 {
                    if !viewModel.movies.isEmpty {
                        ScrollView(showsIndicators: false) {
                            LazyVGrid(columns: columns) {
                                ForEach(viewModel.movies.indices, id: \.self) { index in
                                    let movie = viewModel.movies[index]
                                    DefaultDesign.MovieCard(movies: movie, onLike: {_ in
                                        viewModel.movies.removeAll(where: {$0.id == movie.id})
                                        DispatchQueue.main.async {
                                            viewModel.fetchMovie()
                                        }
                                    })
                                    .id(movie.id)
                                }
                            }
                        }
                    } else {
                        VStack {
                            Spacer()
                            Image("ic_no_favorite")
                                .resizable()
                                .frame(width: 120, height: 120, alignment: .center)
                            
                            Text(Strings.noFavourite)
                                .foregroundColor(.whiteColour)
                                .font(.system(size: 18, weight: .medium))
                            
                            Text(Strings.noFavouriteMovie)
                                .foregroundColor(.grayColour)
                                .font(.system(size: 14, weight: .regular))
                            
                            Spacer()
                        }
                    }
                } else {
                    if !viewModel.series.isEmpty {
                        ScrollView(showsIndicators: false) {
                            LazyVGrid(columns: columns) {
                                ForEach(viewModel.series.indices, id: \.self) { index in
                                    let movie = viewModel.series[index]
                                    DefaultDesign.MovieCard(movies: movie, onLike: {_ in
                                        viewModel.series.removeAll(where: {$0.id == movie.id})
                                        DispatchQueue.main.async {
                                            viewModel.fetchMovie()
                                        }
                                    })
                                    .id(movie.id)
                                }
                            }
                        }
                    } else {
                        VStack {
                            Spacer()
                            Image("ic_no_favorite")
                                .resizable()
                                .frame(width: 120, height: 120, alignment: .center)
                            
                            Text(Strings.noFavourite)
                                .foregroundColor(.whiteColour)
                                .font(.system(size: 18, weight: .medium))
                            
                            Text(Strings.noFavouriteSeries)
                                .foregroundColor(.grayColour)
                                .font(.system(size: 14, weight: .regular))
                            Spacer()
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
        }
        .defaultPage()
    }
}

#Preview {
    LikedScreen()
}
