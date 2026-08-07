//
//  HomeViewModel.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 24/07/26.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var topRatedMovie: [Movie] = []
    @Published var celebrity: CelebrityResponse?
    @Published var moviesBunch: MediaBunch?
    @Published var discover: [OnBordingInfo] = [OnBordingInfo(id: 0, image: "ic_compas", name: "COMPASS", info: "NAV_TOOL"),
                                                OnBordingInfo(id: 1, image: "ic_photo_edit", name: "EDIT_PHOTO", info: "EDIT_PHOTO"),
                                                OnBordingInfo(id: 2, image: "ic_photo_cleander", name: "PHOTO_CLEANER", info: "FIND_DUBLICATE"),
                                                OnBordingInfo(id: 3, image: "ic_sound_meter", name: "SOUND_METER", info: "MEASURE_NOICE")]
    init() {
        self.topRatedMovieAPI()
    }
    
    // MARK: - API Call's -
    func topRatedMovieAPI() {
        if Utility.isInternetAvailable() {
            HomeServices.shared.topRatedAPI { statusCode, response in
                let movieData = response.results.prefix(10)
                self.topRatedMovie = Array(repeating: movieData, count: 100).flatMap { $0 }
                self.celebrityAPI()
            } failure: { error in
                print(error)
            }
        } else {
            Toast.shared.show(message: noInternet, type: .error)
        }
    }
    
    func celebrityAPI() {
        if Utility.isInternetAvailable() {
            HomeServices.shared.celecrityAPI(page: 1) { statusCode, response in
                self.celebrity = response
                self.newReleaseAPI()
            } failure: { error in
                print(error)
            }
        } else {
            Toast.shared.show(message: noInternet, type: .error)
        }
    }
    
    func newReleaseAPI() {
        if Utility.isInternetAvailable() {
            DiscoverService.shared.newReleaseAPI { statusCode, response in
                self.moviesBunch = MediaBunch(id: 0, name: "NEW_RELEASE", type: .NewRelesesMovie, media: response)
            } failure: { error in
                print(error)
            }
        } else {
            Toast.shared.show(message: noInternet, type: .error)
        }
    }
}
