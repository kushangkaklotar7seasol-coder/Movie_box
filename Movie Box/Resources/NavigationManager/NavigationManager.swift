//
//  NavigationManager.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 24/07/26.
//

import Foundation
internal import Combine
import SwiftUI

enum Route: Hashable {
    case language(isShowBackButton: Bool)
    case intro
    
    case tab
    case home
    case artist(artistDetail: CelebrityResponse?)
    case movieList(movieBunch: MediaBunch?)
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
