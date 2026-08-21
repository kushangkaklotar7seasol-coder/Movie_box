//
//  ArtistViewModel.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 25/07/26.
//

import Foundation
import Combine

class ArtistViewModel: ObservableObject {
    @Published var celebrity: CelebrityResponse?
    @Published var isLoading: Bool = false
    
    init(celebrity: CelebrityResponse? = nil) {
        self.celebrity = celebrity
        self.celebrityAPI()
    }
    
    func celebrityAPI() {
        if Utility.isInternetAvailable() {
            self.isLoading = true
            HomeServices.shared.celecrityAPI(page: (celebrity?.page ?? 1) + 1) { statusCode, response in
                self.isLoading = false
                for i in response.results {
                    self.celebrity?.results.append(i)
                }
                self.celebrity?.totalPages = response.totalPages
                self.celebrity?.totalResults = response.totalResults
                self.celebrity?.page += 1
            } failure: { error in
                print(error)
                self.isLoading = false
            }
        } else {
            Toast.shared.show(message: noInternet, type: .error)
        }
    }
}
