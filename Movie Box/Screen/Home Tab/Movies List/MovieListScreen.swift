//
//  MovieListScreen.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 25/07/26.
//

import SwiftUI

struct MovieListScreen: View {
    @StateObject var viewModel: MovieListViewModel
    
    let columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]
    
    var body: some View {
        ZStack {
            VStack {
                DefaultDesign.Header(name: viewModel.moviesBunch?.name.localized() ?? "")
                
                let array = viewModel.mediaItem
                
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(array.indices, id: \.self) { index in
                            let movie = array[index]
                            DefaultDesign.MovieCard(movies: movie)
                                .onAppear() {
                                    self.loadMoreIfNeeded(currentItem: index)
                                }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .defaultPage()
    }
    
    func loadMoreIfNeeded(currentItem: Int) {
        guard !viewModel.isLoading, currentItem >= viewModel.mediaItem.count - 4 else { return }
        viewModel.newReleaseAPI()
    }
}

#Preview {
    MovieListScreen(viewModel: MovieListViewModel())
}
