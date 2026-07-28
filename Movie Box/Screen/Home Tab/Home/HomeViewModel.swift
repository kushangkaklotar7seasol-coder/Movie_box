//
//  HomeViewModel.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 24/07/26.
//

import Foundation
internal import Combine

class HomeViewModel: ObservableObject {
    @Published var topRatedMovie: [Movie] = []
    @Published var celebrity: CelebrityResponse?
    @Published var moviesBunch: MediaBunch?
    @Published var discover: [OnBordingInfo] = [OnBordingInfo(id: 0, image: "ic_compas", name: Strings.compass, info: Strings.navTool),
                                                OnBordingInfo(id: 1, image: "ic_photo_edit", name: Strings.photoEdit, info: Strings.editPhoto),
                                                OnBordingInfo(id: 2, image: "ic_photo_cleander", name: Strings.photoCleaner, info: Strings.findDublicate),
                                                OnBordingInfo(id: 3, image: "ic_sound_meter", name: Strings.soundMeter, info: Strings.mesureNoice)]
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
                self.moviesBunch = MediaBunch(id: 0, name: Strings.newRelease, type: .NewRelesesMovie, media: response)
            } failure: { error in
                print(error)
            }
        } else {
            Toast.shared.show(message: noInternet, type: .error)
        }
    }
}
