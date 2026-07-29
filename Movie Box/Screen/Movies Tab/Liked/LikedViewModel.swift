//
//  LikedViewModel.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 29/07/26.
//

import Foundation
import Combine

class LikedViewModel: ObservableObject {
    @Published var movies: [MediaItem] = []
    @Published var series: [MediaItem] = []
    @Published var selectedIndex = 0
    
    init() {
        for i in database.fetchMovies() {
            if i.isMovie == 1 {
                self.movies.append(i)
            } else {
                self.series.append(i)
            }
        }
    }
    
    func fetchMovie(){
        for i in database.fetchMovies() {
            if i.isMovie == 1 {
                self.movies.append(i)
            }
        }
    }
    
    func fetchSeries(){
        for i in database.fetchMovies() {
            if i.isMovie != 1 {
                self.series.append(i)
            }
        }
    }
}
