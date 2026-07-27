//
//  Movie_BoxApp.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 24/07/26.
//

import SwiftUI
internal import Combine

@main
struct Movie_BoxApp: App {
    @StateObject private var localization = LocalizationManager.shared
    @StateObject private var router = Router.shared
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                NavigationStack(path: $router.path) {
                    SplashScreen()
                        .toolbar(.hidden, for: .navigationBar)
                        .preferredColorScheme(.dark)
                        .navigationDestination(for: Route.self) { route in
                            destination(for: route)
                        }
                }
                .environment(\.locale, Locale(identifier: localization.selectedLanguage))
                .environmentObject(localization)
            }
        }
    }
    
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
        }
    }
}
