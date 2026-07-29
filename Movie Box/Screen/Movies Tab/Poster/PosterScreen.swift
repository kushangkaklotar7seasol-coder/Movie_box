//
//  PosterScreen.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 28/07/26.
//

import SwiftUI
import Kingfisher

struct PosterScreen: View {
    @StateObject var viewModel: PosterViewModel
    let columns = [
       GridItem(.flexible()),
       GridItem(.flexible())
   ]
    
    var body: some View {
        ZStack {
            VStack {
                DefaultDesign.Header(name: "Poster")
                
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns) {
                        ForEach(viewModel.images.indices, id: \.self) { index in
                            
                            let image = viewModel.images[index]
                            ZStack {
                                KFImage.url(URL(string: imageUrl+image.filePath))
                                    .placeholder({ progress in
                                        let placeHolderImage = "img_noimage"
                                        Image(placeHolderImage)
                                            .resizable()
                                            .scaledToFill()
                                    })
                                    .resizable()
                                    .scaledToFill()
                            }
                            .frame(width: (screenWidth-32)/2.1, height: (screenWidth-32)/1.7, alignment: .center)
                            .background()
                            .cornerRadius(24)
                            .onTapGesture {
                                viewModel.posterIndex = index
                                viewModel.isShowPosterDetail = true
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .defaultPage()
        .sheet(isPresented: $viewModel.isShowPosterDetail) {
            PhotoPreviewSheet(images: viewModel.images,
                              selectedPosterIndex: viewModel.posterIndex)
        }
    }
}

#Preview {
    PosterScreen(viewModel: PosterViewModel())
}
