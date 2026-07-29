//
//  VideosScreen.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 29/07/26.
//

import SwiftUI
import Kingfisher
import _WebKit_SwiftUI

struct VideosScreen: View {
    @StateObject var viewModel: VideoViewModel
    
    var body: some View {
        ZStack {
            VStack {
                DefaultDesign.Header(name: "Video")
                
                ScrollView {
                    ForEach(viewModel.videos.indices, id: \.self) { index in
                        let video = viewModel.videos[index]
                        
                        ZStack {
                            KFImage.url(URL(string: "https://img.youtube.com/vi/\(video.key)/hqdefault.jpg"))
                                .placeholder({ progress in
                                    let placeHolderImage = "img_noimage"
                                    Image(placeHolderImage)
                                        .resizable()
                                        .scaledToFill()
                                })
                                .resizable()
                                .scaledToFill()
                            
                            if isYoutubeEnabled {
                                Image("ic_play")
                                    .resizable()
                                    .frame(width: 30, height: 30, alignment: .center)
                            }
                        }
                        .frame(width: screenWidth-32, height: (screenHeight-150)/3, alignment: .center)
                        .background()
                        .cornerRadius(24)
                        .onTapGesture {
                            if isYoutubeEnabled {
                                viewModel.youtubeUrl = "https://www.youtube.com/watch?v=\(video.key)"
                                viewModel.isYoutubeVideo = true
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .defaultPage()
        .sheet(isPresented: $viewModel.isYoutubeVideo) {
            NavigationStack {
                WebView(url: URL(string: viewModel.youtubeUrl)!)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") {
                                viewModel.isYoutubeVideo = false
                            }
                        }
                    }
            }
        }
    }
}

#Preview {
    VideosScreen(viewModel: VideoViewModel())
}
