//
//  SplashViewModel.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 24/07/26.
//

import Foundation
internal import Combine

class SplashViewModel: ObservableObject {

    init() {
        self.navigationManager()
    }
    
    func navigationManager() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
             let onBoarding = UserdefaultManager.shared.getIntro()
            let language = UserdefaultManager.shared.getLanguage()
            
            if language == nil {
                Router.shared.push(.language(isShowBackButton: false))
                return
            }
            
            if onBoarding == 0 {
                Router.shared.push(.tab)
                return
            }
            
            Router.shared.push(.intro)
        }
    }
}
