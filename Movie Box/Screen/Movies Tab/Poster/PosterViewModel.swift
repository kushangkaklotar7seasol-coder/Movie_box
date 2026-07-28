//
//  PosterViewModel.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 28/07/26.
//

import Foundation
internal import Combine

class PosterViewModel: ObservableObject {
    @Published var images: [MovieImage] = []
    @Published var posterIndex: Int = 0
    @Published var isShowPosterDetail = false
    
    init(images: [MovieImage] = []) {
        self.images = images
    }
}
