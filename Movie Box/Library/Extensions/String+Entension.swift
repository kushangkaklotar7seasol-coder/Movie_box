//
//  String+Entension.swift
//  Korvani
//
//  Created by Kushang kaklotar on 10/07/26.
//

import Foundation

extension String {
    func localized() -> String {
        let loc = UserdefaultManager.shared.getLanguage()?.code ?? "en"
        let path = Bundle.main.path(forResource: loc, ofType: "lproj")
        let bundle = Bundle(path: path!)
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }

    func localizedLan(loc: String) -> String {
        let path = Bundle.main.path(forResource: "en", ofType: "lproj")
        let bundle = Bundle(path: path!)
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
}

class Strings {
    // MARK: - Language screen -
    static var chooseLanguage: String { "CHOOSE_LANGUAGE".localized() }
    static var done: String { "DONE".localized() }
    
    // MARK: -  Intro Screen -
    static var page1Title: String { "PAGE1_TITLE".localized() }
    static var page1Info: String { "PAGE1_INFO".localized() }
    static var page2Title: String { "PAGE2_TITLE".localized() }
    static var page2Info: String { "PAGE2_INFO".localized() }
    static var page3Title: String { "PAGE3_TITLE".localized() }
    static var page3Info: String { "PAGE3_INFO".localized() }
    static var next: String { "NEXT".localized() }
    static var getStated: String { "GET_STATED".localized() }
    
    // MARK: - Home Screen -
    static var welcomeBack: String { "WELCOME_BACK".localized() }
    static var quickDiscover: String { "QUICK_DISCOVER".localized() }
    static var compass: String { "COMPASS".localized() }
    static var navTool: String { "NAV_TOOL".localized() }
    static var photoEdit: String { "PHOTO_EDIT".localized() }
    static var editPhoto: String { "EDIT_PHOTO".localized() }
    static var photoCleaner: String { "PHOTO_CLEANER".localized() }
    static var findDublicate: String { "FIND_DUBLICATE".localized() }
    static var soundMeter: String { "SOUND_METER".localized() }
    static var mesureNoice: String { "MEASURE_NOICE".localized() }
    static var sportLightArtist: String { "SPOTLIGHT_ARTIST".localized() }
    static var newRelease: String { "NEW_RELEASE".localized() }
    
    // MARK: - Compass -
    static var highPrecision: String { "HIGH_PRECISION".localized() }
    static var calibrating: String { "CALIBRATING".localized() }
    static var latitude: String { "LATITUDE".localized() }
    static var longtitude: String { "LONGITUDE".localized() }
    static var north: String { "DIR_N".localized() }
    static var northNorthest: String { "DIR_NNE".localized() }
    static var northest: String { "DIR_NE".localized() }
    static var easthNorthest: String { "DIR_ENE".localized() }
    static var east: String { "DIR_E".localized() }
    static var eastSouthest: String { "DIR_ESE".localized() }
    static var southest: String { "DIR_SE".localized() }
    static var southSouthest: String { "DIR_SSE".localized() }
    static var south: String { "DIR_S".localized() }
    static var southSouthwest: String { "DIR_SSW".localized() }
    static var southWest: String { "DIR_SW".localized() }
    static var westSouthWest: String { "DIR_WSW".localized() }
    static var west: String { "DIR_W".localized() }
    static var westNorthWest: String { "DIR_WNW".localized() }
    static var northWest: String { "DIR_NW".localized() }
    static var northNorthWest: String { "DIR_NNW".localized() }
    
    // MARK: - Photo Cleaner Screen -
    static var dublicatePhotoFound: String { "DUBLICATE_PHOTO_FOUND".localized() }
    static var group: String { "GROUP".localized() }
    static var noDublicate: String { "NO_DUBLICATE_PIC".localized() }
    static var noDublicateInfo: String { "NO_DUBLICATE_PIC_INFO".localized() }
    static var scaning: String { "SCANING".localized() }
    static var permissionNote: String { "PERMISSION_NOTE".localized() }
    static var deleteMedia: String { "DELETE_MEDIA".localized() }
    static var selectAll: String { "SELECT_ALL".localized() }
    static var removeAll: String { "REMOVE_ALL".localized() }
    static var photoAccess: String { "PHOTO_ACCESS".localized() }
    static var allowPhotoAccess: String { "ALLOW_PHOTO_ACCESS".localized() }
    
    // MARK: - Media Meter Screen -
    static var decibles: String { "DECIBELS".localized() }
    static var avg: String { "AVG".localized() }
    static var min: String { "MIN".localized() }
    static var max: String { "MAX".localized() }
    static var stop: String { "STOP".localized() }
    static var start: String { "START".localized() }
    static var restart: String { "RESTART".localized() }
    static var openSettings: String { "OPEN_SETTINGS".localized() }
    static var microphoneAccess: String { "MICROPHONE_ACCESS".localized() }
    static var allowMicrohoneAccess: String { "ALLOW_MICROPHONE_ACCESS".localized() }
    static var cancel: String { "CANCEL".localized() }
    
    // MARK: - Actor Detail -
    static var biography: String { "BIOGRAPHY".localized() }
    static var movie: String { "MOVIE".localized() }
    static var tvShow: String { "TVSHOW".localized() }
    static var birthday: String { "BIRTHDAY".localized() }
    static var birthPlace: String { "BIRTHPLACE".localized() }
    static var age: String { "AGE".localized() }
    static var department: String { "DEPARTMENT".localized() }
    static var personalInfo: String { "PERSONAL_INFO".localized() }
    
    // MARK: - Search Screen -
    static var searchMoviePlaceholder: String { "SEARCH_MEDIA".localized() }
    static var newSearchPlaceholder: String { "NEWEARCH_PLACEHOLDER".localized() }
    static var noSearchData: String { "NO_SEARCH_DATA".localized() }
    static var noSearchDataFor: String { "NO_SEARCH_DATA_FOUND".localized() }
    static var topRated: String { "TOP_RATED".localized() }
    static var mostPopuler: String { "MOST_POPULAR".localized() }
    static var arrivingToday: String { "ARRIVING_TODAY".localized() }
    static var seeAll: String { "SEE_ALL".localized() }
    
    // MARK: - Movie Detail -
    static var topCast: String { "TOP_CAST".localized() }
    static var coreCrew: String { "CORE_CREW".localized() }
    static var status: String { "STATUS".localized() }
    static var language: String { "LANGUAGE".localized() }
    static var runtime: String { "RUNTIME".localized() }
    static var revenue: String { "REVENUE".localized() }
    static var poster: String { "POSTER".localized() }
    static var videos: String { "VIDEOS".localized() }
    static var shareText1: String { "SHARE_TEXT1".localized() }
    static var shareText2: String { "SHARE_TEXT2".localized() }
    static var season: String { "SEASON".localized() }
    static var overview: String { "OVERVIEW".localized() }
    static var movieInfo: String { "MOVIE_INFO".localized() }
    static var crew: String { "CREW".localized() }
    static var posters: String { "POSTERS".localized() }
    
    // MARK: - Favorite -
    static var favourite: String { "FAVORITE".localized() }
    static var noFavourite: String { "NO_FAVORITE".localized() }
    static var noFavouriteMovie: String { "NO_MOVIE_TAGLINE".localized() }
    static var noFavouriteSeries: String { "NO_SERIES_TAGLINE".localized() }
    
    // MARK: - Notes -
    static var notes: String { "NOTES".localized() }
    static var addNotes: String { "ADD_NOTES".localized() }
    static var editNotes: String { "EDIT_NOTES".localized() }
    static var deleteNotes: String { "DELETE_NOTES".localized() }
    static var no: String { "NO".localized() }
    static var delete: String { "DELETE".localized() }
    static var deleteInfo: String { "DELETE_INFO".localized() }
    static var unPin: String { "UNPIN".localized() }
    static var pin: String { "PIN".localized() }
    static var share: String { "SHARE".localized() }
    static var noNotes: String { "NO_NOTES".localized() }
    static var noNotesInfo: String { "NO_NOTES_INFO".localized() }
    static var noPinnedNotes: String { "NO_PINNED_NOTES".localized() }
    static var noPinnedNotesInfo: String { "NO_PINNED_NOTES_INFO".localized() }
    
    // MARK: - Add Note -
    static var noteTitle: String { "NOTE_TITLE".localized() }
    static var startTyping: String { "START_TYPING".localized() }
    static var updateNote: String { "UPDATE_NOTE".localized() }
    static var saveNote: String { "SAVE_NOTE".localized() }
    static var pinnedNotes: String { "PINNED_NOTES".localized() }
    
    // MARK: - Setting -
    static var setting: String { "SETTING".localized() }
    static var shareApp: String { "SHARE_APP".localized() }
    static var rateUs: String { "RATE_US".localized() }
    static var privecyPolicy: String { "PRIVECY_POLICY".localized() }
    static var termaUse: String { "TERMS_USE".localized() }
    static var aboutUs: String { "ABOUT_US".localized() }
}
