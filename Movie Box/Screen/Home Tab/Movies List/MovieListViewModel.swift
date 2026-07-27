//
//  MovieListViewModel.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 25/07/26.
//

import Foundation
internal import Combine

class MovieListViewModel: ObservableObject {
    @Published var moviesBunch: MediaBunch?
    @Published var mediaCredits: MediaCredits?
    @Published var mediaItem: [MediaItem] = []
    @Published var isLoading: Bool = false
    
    init(moviesBunch: MediaBunch? = nil){
        self.moviesBunch = moviesBunch
        
        self.mediaCredits = moviesBunch?.media
        self.mediaItem = moviesBunch?.media.results ?? []
        
        self.newReleaseAPI()
    }
    
    func newReleaseAPI() {
        if Utility.isInternetAvailable() {
            self.isLoading = true
            DiscoverService.shared.newReleaseAPI(page: (self.mediaCredits?.page ?? 0)+1) { statusCode, response in
                self.isLoading = false
                self.mediaCredits = response
                for i in response.results {
                    self.mediaItem.append(i)
                }
            } failure: { error in
                self.isLoading = false
                print(error)
            }
        } else {
            Toast.shared.show(message: noInternet, type: .error)
        }
    }
    
}
