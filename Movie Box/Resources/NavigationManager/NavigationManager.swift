//
//  NavigationManager.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 24/07/26.
//

import Foundation
import Combine
import SwiftUI

@ViewBuilder
func destination(for route: Route) -> some View {
    switch route {
    case .language(let isShowBackButton):
        LanguageScreen(viewModel: LanguageViewModel(isShowBack: isShowBackButton))
    case .intro:
        IntroScreen()
    case .splash:
        SplashScreen()
    case .tab:
        TabBarScreen()
    case .home:
        HomeScreen()
    case .artist(let artistDetail):
        ArtistScreen(viewModel: ArtistViewModel(celebrity: artistDetail))
    case .movieList(let mediaBunch):
        MovieListScreen(viewModel: MovieListViewModel(moviesBunch: mediaBunch))
    case .artistDetail(let id):
        ArtistDetail(viewModel: ArtistDetailViewModel(celebrityId: id))
    case .compass:
        CompassScreen()
    case .photoCleaner:
        PhotoCleanerScreen()
    case .soundMeter:
        SoundMeterScreen()
    case .photoEdit:
        PhotoEditScreen()
    case .search:
        SearchScreen()
    case .categoryList(let mediaBunch):
        CategoryListScreen(viewModel: CategoryListViewModel(media: mediaBunch))
    case .movieDetail(let movieId, let isMovie):
        MovieDetailScreen(viewModel: MovieDetailViewModel(movieId: movieId, isMovie: isMovie))
    case .poster(let poster):
        PosterScreen(viewModel: PosterViewModel(images: poster))
    case .videoList(let video):
        VideosScreen(viewModel: VideoViewModel(videos: video))
    case .liked:
        LikedScreen()
    case .addNote(let notes):
        AddNotesScreen(viewModel: AddNotesViewModel(oldNote: notes))
    case .pinedNotes:
        PinedNotesScreen()
    case .posterDetail(let movies, let index):
        PhotoPreviewSheet(images: movies, selectedPosterIndex: index)
    }
}

enum Route: Hashable {
    case language(isShowBackButton: Bool)
    case intro
    case splash
    
    case tab
    case home
    case artist(artistDetail: CelebrityResponse?)
    case movieList(movieBunch: MediaBunch?)
    case artistDetail(artistId: Int)
    case compass
    case photoCleaner
    case soundMeter
    case photoEdit
    case search
    case categoryList(movieBunch: MediaBunch?)
    case movieDetail(movieId: Int, isMovie: Bool)
    case poster(posters: [MovieImage])
    case videoList(video: [Video])
    case liked
    case addNote(notes: Notes?)
    case pinedNotes
    case posterDetail(movies: [MovieImage], index: Int)
}

final class Router: ObservableObject {
    static let shared = Router()
    @Published var path = NavigationPath()
    @Published var rootRoute: Route = .splash
    
    func push(_ route: Route) {
        path.append(route)
    }
    
    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    func updateRoot(_ route: Route) {
        path.removeLast(path.count)
        rootRoute = route
    }
}

extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
