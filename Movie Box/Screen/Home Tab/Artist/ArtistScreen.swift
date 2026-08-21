//
//  ArtistScreen.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 25/07/26.
//

import SwiftUI

struct ArtistScreen: View {
    @StateObject var viewModel: ArtistViewModel
    @State var refreshID = UUID()
    
    var columns: [GridItem] {
        let count = Device.isiPadPortrait ? 5 : Device.isiPadLandscape ? 6 : 3
        return Array(repeating: GridItem(.flexible(), spacing: 15), count: count)
    }
    
    var body: some View {
        ZStack {
            VStack {
                DefaultDesign.Header(name: Strings.sportLightArtist)
                    .padding(.horizontal, 16)
                
                ScrollView(showsIndicators: false) {
                    if let array = viewModel.celebrity?.results {
                        LazyVGrid(columns: columns, spacing: 15) {
                            ForEach(Array(array.enumerated()), id: \.offset) { index, person in
                                DefaultDesign.PersonPoster(url: person.profilePath ?? "", name: person.name)
                                    .onAppear {
                                        loadMoreIfNeeded(currentItem: index)
                                    }
                                    .onTapGesture {
                                        Router.shared.push(.artistDetail(artistId: person.id))
                                    }
                            }
                        }
                        .padding(.horizontal)
                        .id(refreshID)
                        
                        if viewModel.isLoading {
                            ProgressView()
                                .padding()
                        }
                    }
                }
            }
        }
        .defaultPage(true)
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            refreshID = UUID()
        }
    }
    
    func loadMoreIfNeeded(currentItem: Int) {
        guard let totalCount = viewModel.celebrity?.results.count else { return }
        let thresholdIndex = max(0, totalCount - 4)
        
        if currentItem >= thresholdIndex {
            viewModel.celebrityAPI()
        }
    }
}
#Preview {
    ArtistScreen(viewModel: ArtistViewModel())
}
