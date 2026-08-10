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
    var columns: [GridItem] {
        let count = Device.isiPadPortrait ? 3 : Device.isiPadLandscape ? 4 : 2
        return Array(repeating: GridItem(.flexible(), spacing: 15), count: count)
    }
    @State var refreshID = UUID()
    var posterWidth: CGFloat {
        
        if Device.isiPadLandscape {
            return (screenWidth-32)/4.1
        } else if Device.isIpad {
            return (screenWidth-32)/3.1
        } else {
            return (screenWidth-32)/2.1
        }
    }
    
    var posterHeight: CGFloat {
        if Device.isiPadLandscape {
            return (screenWidth-32)/3.7
        } else if Device.isIpad {
            return (screenWidth-32)/2.7
        } else {
            return (screenWidth-32)/1.7
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
                DefaultDesign.Header(name: Strings.posters)
                
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
                            .frame(width: posterWidth, height: posterHeight, alignment: .center)
                            .cornerRadius(24)
                            .onTapGesture {
                                Router.shared.push(.posterDetail(movies: viewModel.images, index: index))
                            }
                        }
                    }
                    .id(refreshID)
                }
            }
            .padding(.horizontal, 16)
        }
        .defaultPage()
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            refreshID = UUID()
        }
    }
}

#Preview {
    PosterScreen(viewModel: PosterViewModel())
}
