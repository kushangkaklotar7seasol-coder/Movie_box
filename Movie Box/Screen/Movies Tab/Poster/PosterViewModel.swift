//
//  PosterViewModel.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 28/07/26.
//

import Foundation
import Combine

class PosterViewModel: ObservableObject {
    @Published var images: [MovieImage] = []
    
    init(images: [MovieImage] = []) {
        self.images = images
    }
}
