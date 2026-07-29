//
//  IntroViewModel.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 24/07/26.
//

import Foundation
import Combine

class IntroViewModel: ObservableObject {
    @Published var information: [OnBordingInfo] = [OnBordingInfo(id: 0, image: "img_intro_1", name: Strings.page1Title, info: Strings.page1Info),
                                                   OnBordingInfo(id: 1, image: "img_intro_2", name: Strings.page2Title, info: Strings.page2Info),
                                                   OnBordingInfo(id: 2, image: "img_intro_3", name: Strings.page3Title, info: Strings.page3Info)]
}
