//
//  ArtistScreen.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 25/07/26.
//

import SwiftUI

struct ArtistScreen: View {
    @StateObject var viewModel: ArtistViewModel
    
    let columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]
    
    var body: some View {
        ZStack {
            VStack {
                DefaultDesign.Header(name: "Spotlight Artist")
                    .padding(.horizontal, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack {
                        if let array = viewModel.celebrity?.results {
                            ScrollView {
                                LazyVGrid(columns: columns, spacing: 15) {
                                    ForEach(array.indices, id: \.self) { index in
                                        let person = array[index]
                                        DefaultDesign.PersonPoster(url: person.profilePath ?? "", name: person.name)
                                            .onAppear() {
                                                loadMoreIfNeeded(currentItem: index)
                                            }
                                            .onTapGesture {
                                                Router.shared.push(.artistDetail(artistId: person.id))
                                            }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .defaultPage(true)
    }
    
    
    func loadMoreIfNeeded(currentItem: Int) {
        guard !viewModel.isLoading, currentItem == (viewModel.celebrity?.results.count ?? 0) - 5 else { return }
        viewModel.celebrityAPI()
    }
}

#Preview {
    ArtistScreen(viewModel: ArtistViewModel())
}
