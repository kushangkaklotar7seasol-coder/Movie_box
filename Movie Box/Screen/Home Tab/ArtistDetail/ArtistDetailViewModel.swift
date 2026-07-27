//
//  ArtistDetailViewModel.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 27/07/26.
//

import Foundation
internal import Combine

class ArtistDetailViewModel: ObservableObject {
    @Published var personalDetail: [PersonalDetail] = []
    @Published var isLoading = false
    @Published var celebrityDetail: PersonDetail?
    @Published var movieCredits: PersonMovieCredits?
    @Published var seriesCredits: PersonTVCredits?
    @Published var moviesBunch: [MediaBunch] = []
    @Published var isViewAllSheet: Bool = false
    @Published var type: Int = 0 //0=Movie, 1=Series
    
    var celebrityId: Int
    
    init(celebrityId: Int? = 122822) {
        self.celebrityId = celebrityId ?? 0
        self.celebrotyDetailAPI()
    }
    
    func celebrotyDetailAPI() {
        if Utility.isInternetAvailable() {
            CelebrityService.shared.celecrityDetailAPI(personId: self.celebrityId) { statusCode, response in
                self.celebrityDetail = response
                
                if let birthDay = self.celebrityDetail?.birthday {
                    self.personalDetail.append(PersonalDetail(id: 0, name: "Birthday", value: birthDay))
                }
                
                if let placeBirth = self.celebrityDetail?.placeOfBirth {
                    self.personalDetail.append(PersonalDetail(id: 1, name: "Birthplace", value: placeBirth))
                }
                
                if let bornYear = self.celebrityDetail?.birthday?.prefix(4) {
                    let currentYear = Calendar.current.component(.year, from: Date())
                    self.personalDetail.append(PersonalDetail(id: 2, name: "Birthplace", value: "\(currentYear - (Int(bornYear) ?? 0))"))
                }
                
                if let department = self.celebrityDetail?.knownForDepartment {
                    self.personalDetail.append(PersonalDetail(id: 3, name: "Department", value: department))
                }
                
                self.moviesAPI()
            } failure: { error in
                print(error)
            }
        } else {
            Toast.shared.show(message: noInternet, type: .error)
        }
    }
    
    func moviesAPI() {
        if Utility.isInternetAvailable() {
            self.isLoading = true
            CelebrityService.shared.celebrityMovieAPI(personId: self.celebrityId) { statusCode, response in
                self.isLoading = false
                self.movieCredits = response
                self.tvShowAPI()
            } failure: { error in
                self.isLoading = false
                print(error)
            }
        } else {
            Toast.shared.show(message: noInternet, type: .error)
        }
    }
    
    func tvShowAPI() {
        if Utility.isInternetAvailable() {
            self.isLoading = true
            CelebrityService.shared.celebrityTvSeriesAPI(personId: self.celebrityId) { statusCode, response in
                self.isLoading = false
                self.seriesCredits = response
            } failure: { error in
                self.isLoading = false
                print(error)
            }
        } else {
            Toast.shared.show(message: noInternet, type: .error)
        }
    }
}
