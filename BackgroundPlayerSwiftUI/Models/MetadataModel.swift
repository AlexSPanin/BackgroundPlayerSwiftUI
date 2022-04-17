//
//  MetadataModel.swift
//  BackgroundPlayerSwiftUI
//
//  Created by Александр Панин on 17.04.2022.
//

import Foundation

struct StaticMetadataModel {
    let urlString: String                   // MPNowPlayingInfoPropertyAssetURL
    let title: String                   // MPMediaItemPropertyTitle
    let artist: String = "Unkowded"                // MPMediaItemPropertyArtist
    
    init(title: String) {
        self.title = title
        self.urlString = Bundle.main.url(forResource: title, withExtension: "mp3")?.absoluteString ?? ""
    }
    
    
}

struct DynamicMetadataModel {
    let rate: Float                     // MPNowPlayingInfoPropertyPlaybackRate
    let position: Float                 // MPNowPlayingInfoPropertyElapsedPlaybackTime
    let duration: Float                 // MPMediaItemPropertyPlaybackDuration
}
