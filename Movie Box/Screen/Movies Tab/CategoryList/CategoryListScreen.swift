//
//  CategoryListScreen.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 28/07/26.
//

import SwiftUI

struct CategoryListScreen: View {
    @StateObject var viewModel: CategoryListViewModel
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            VStack {
                DefaultDesign.Header(name: viewModel.media.name.localized())
                
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns) {
                        ForEach(viewModel.mediaItem.indices, id: \.self) { index in
                            DefaultDesign.MovieCard(movies: viewModel.mediaItem[index])
                                .onTapGesture {
                                    viewModel.selectedMovieId = viewModel.mediaItem[index].id
                                    viewModel.isShowmovieDetail = true
                                }
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
        guard !viewModel.isLoading, currentItem == viewModel.mediaItem.count - 5 else { return }
        viewModel.manageAPIs()
    }
}

#Preview {
    CategoryListScreen(viewModel: CategoryListViewModel())
}
