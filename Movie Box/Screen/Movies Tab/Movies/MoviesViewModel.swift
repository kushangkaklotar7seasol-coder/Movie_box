//
//  MoviesViewModel.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 28/07/26.
//

import Foundation
import Combine

class MoviesViewModel: ObservableObject {
    @Published var selectedIndex = 0
    @Published var moviesBunch: [MediaBunch] = []
    @Published var seriesBunch: [MediaBunch] = []
    
    @Published var selectedBunch: MediaBunch?
    @Published var isShowLikeScreen = false
    
    @Published var selectedMovie: MediaItem?
    @Published var isShowmovieDetail = false
    
    init() {
        self.newReleaseAPI()
    }
    
    // MARK: - API Call's
    func newReleaseAPI() {
        if Utility.isInternetAvailable() {
            DiscoverService.shared.newReleaseAPI { statusCode, response in
                self.moviesBunch.append(MediaBunch(id: 0, name: Strings.newRelease, type: .NewRelesesMovie, media: response))
                self.topRatedAPI()
            } failure: { error in
                print(error)
            }
        } else {
            Toast.shared.show(message: noInternet, type: .error)
        }
    }
    
    func topRatedAPI() {
        if Utility.isInternetAvailable() {
            DiscoverService.shared.topRatedAPI { statusCode, response in
                self.moviesBunch.append(MediaBunch(id: 1, name: Strings.topRated, type: .TopRatedMovie, media: response))
                self.populerAPI()
            } failure: { error in
                print(error)
            }
        } else {
            Toast.shared.show(message: noInternet, type: .error)
        }
    }
    
    func populerAPI() {
        if Utility.isInternetAvailable() {
            DiscoverService.shared.populerAPI { statusCode, response in
                self.moviesBunch.append(MediaBunch(id: 2, name: Strings.mostPopuler, type: .MostPopulerMovie, media: response))
            } failure: { error in
                print(error)
            }
        } else {
            Toast.shared.show(message: noInternet, type: .error)
        }
    }
    
    func airingTodayAPI() {
        if Utility.isInternetAvailable() {
            DiscoverService.shared.airingTodayAPI { statusCode, response in
                self.seriesBunch.append(MediaBunch(id: 0, name: Strings.arrivingToday, type: .airingTodaySeries, media: response))
                self.topRatedSeriesAPI()
            } failure: { error in
                print(error)
            }
        } else {
            Toast.shared.show(message: noInternet, type: .error)
        }
    }
    
    func topRatedSeriesAPI() {
        if Utility.isInternetAvailable() {
            DiscoverService.shared.topRatedSeriesAPI { statusCode, response in
                self.seriesBunch.append(MediaBunch(id: 1, name: Strings.topRated, type: .topRatedSeries, media: response))
                self.populerSeriesAPI()
            } failure: { error in
                print(error)
            }
        } else {
            Toast.shared.show(message: noInternet, type: .error)
        }
    }
    
    func populerSeriesAPI() {
        if Utility.isInternetAvailable() {
            DiscoverService.shared.populerSeriesAPI { statusCode, response in
                self.seriesBunch.append(MediaBunch(id: 2, name: Strings.mostPopuler, type: .mostPopulerSeries, media: response))
            } failure: { error in
                print(error)
            }
        } else {
            Toast.shared.show(message: noInternet, type: .error)
        }
    }
}
