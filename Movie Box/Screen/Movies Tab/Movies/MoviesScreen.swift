//
//  MoviesScreen.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 24/07/26.
//

import SwiftUI

struct MoviesScreen: View {
    @StateObject var viewModel = MoviesViewModel()
    @EnvironmentObject var localization: LocalizationManager
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text(Strings.movie)
                        .font(.system(size: 22, weight: .semibold))
                    
                    Spacer()
                    
                    Button {
                        Router.shared.push(.liked)
                    } label: {
                        Image("ic_unlike")
                            .resizable()
                            .frame(width: 44, height: 44, alignment: .center)
                    }
                }
                .padding(.horizontal, 16)
                
                CustomSegmentedControl(preselectedIndex: $viewModel.selectedIndex, options: [Strings.movie, Strings.tvShow]) { index in
                    if index == 0 {
                        if viewModel.moviesBunch.isEmpty {
                            viewModel.newReleaseAPI()
                        }
                    } else {
                        if viewModel.seriesBunch.isEmpty {
                            viewModel.airingTodayAPI()
                        }
                    }
                }
                .padding(.horizontal, 16)
                
                if viewModel.selectedIndex == 0 {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            ForEach(viewModel.moviesBunch, id: \.id) { item in
                                DefaultDesign.MoviesBunch(moviedbunch: item, onViewMore: {_ in 
                                    viewModel.selectedBunch = item
//                                    viewModel.isShowCategoryScreen = true
                                    Router.shared.push(.categoryList(movieBunch: item))
                                }, onMedia: { movie in
                                    viewModel.selectedMovie = movie
                                    viewModel.isShowmovieDetail = true
                                })
                            }
                        }
                        .padding(.vertical, 24)
                        .padding(.bottom, 80)
                    }
                    .id(localization.selectedLanguage)
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            ForEach(viewModel.seriesBunch, id: \.id) { item in
                                DefaultDesign.MoviesBunch(moviedbunch: item, onViewMore: {_ in
                                    viewModel.selectedBunch = item
//                                    viewModel.isShowCategoryScreen = true
                                    Router.shared.push(.categoryList(movieBunch: item))
                                }, onMedia: { movie in
                                    viewModel.selectedMovie = movie
                                    viewModel.isShowmovieDetail = true
                                })
                            }
                        }
                        .padding(.vertical, 24)
                        .padding(.bottom, 80)
                    }
                    .id(localization.selectedLanguage)
                }
                
                Spacer()
            }
        }
        .defaultPage(false)
    }
}

#Preview {
    MoviesScreen()
}
