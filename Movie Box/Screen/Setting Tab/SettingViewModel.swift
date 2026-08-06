//
//  SettingViewModel.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 30/07/26.
//

import Foundation
import Combine
import UIKit

class SettingViewModel: ObservableObject {
    var settingItem: [PersonalDetail] = [PersonalDetail(id: 0, name: "LANGUAGE", value: "ic_language"),
                                         PersonalDetail(id: 1, name: "SHARE_APP", value: "ic_share_clear"),
                                         PersonalDetail(id: 2, name: "RATE_US", value: "ic_star_white"),
                                         PersonalDetail(id: 3, name: "PRIVECY_POLICY", value: "ic_privacy"),
                                         PersonalDetail(id: 4, name: "TERMS_USE", value: "ic_terms"),
                                         PersonalDetail(id: 5, name: "ABOUT_US", value: "ic_info")]
    
    func onSelect(_ id: Int) {
        switch id {
        case 0:
            Router.shared.push(.language(isShowBackButton: true))
        case 1:
            self.shareApp()
        case 2:
            self.rateApp()
        case 3:
            self.openURL(AppInfo.privacyPolicy)
        case 4:
            self.openURL(AppInfo.termsOfUse)
        case 5:
            print("About Us")
        default: break;
        }
    }
    
    // MARK: - Actions
    func shareApp() {
        let url = URL(string: AppInfo.shareApp)!
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = scene.windows.first?.rootViewController {
            root.present(activityVC, animated: true)
        }
    }

    func rateApp() {
        guard let url = URL(string: AppInfo.rateApp) else { return }
        UIApplication.shared.open(url)
    }

    func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}
