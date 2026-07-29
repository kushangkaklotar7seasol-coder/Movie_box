//
//  VideoViewModel.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 29/07/26.
//

import Foundation
import Combine

class VideoViewModel: ObservableObject {
    var videos: [Video] = []
    @Published var isYoutubeVideo = false
    @Published var youtubeUrl = ""
    
    init(videos: [Video] = []) {
        self.videos = videos
    }
}
