//
//  NavigationManager.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 24/07/26.
//

import Foundation
internal import Combine
import SwiftUI

@ViewBuilder
func destination(for route: Route) -> some View {
    switch route {
    case .language(let isShowBackButton):
        LanguageScreen(viewModel: LanguageViewModel(isShowBack: isShowBackButton))
    case .intro:
        IntroScreen()
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
    }
}

enum Route: Hashable {
    case language(isShowBackButton: Bool)
    case intro
    
    case tab
    case home
    case artist(artistDetail: CelebrityResponse?)
    case movieList(movieBunch: MediaBunch?)
    case artistDetail(artistId: Int)
    case compass
}

final class Router: ObservableObject {
    static let shared = Router()
    @Published var path = NavigationPath()

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
}

extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard SwipeBackManager.shared.isEnabled else { return false }
        return viewControllers.count > 1
    }
}
