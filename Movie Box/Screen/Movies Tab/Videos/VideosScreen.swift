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
    @State var refreshID = UUID()
    
    var body: some View {
        ZStack {
            VStack {
                DefaultDesign.Header(name: Strings.videos)
                
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
                        .frame(width: screenWidth-32, height: Device.isiPadLandscape ? (screenHeight-150)/2 : (screenHeight-150)/3, alignment: .center)
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
                .id(refreshID)
            }
            .padding(.horizontal, 16)
        }
        .defaultPage()
        .sheet(isPresented: $viewModel.isYoutubeVideo) {
            NavigationStack {
                Group {
                    if let url = URL(string: viewModel.youtubeUrl), !viewModel.youtubeUrl.isEmpty {
                        WebView(url: url)
                    } else {
                        ContentUnavailableView("Invalid URL", image: "exclamationmark.triangle")
                    }
                }
                .navigationTitle("YouTube")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            viewModel.isYoutubeVideo = false
                        }
                        .bold()
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            refreshID = UUID()
        }
    }
}

#Preview {
    VideosScreen(viewModel: VideoViewModel())
}

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}
