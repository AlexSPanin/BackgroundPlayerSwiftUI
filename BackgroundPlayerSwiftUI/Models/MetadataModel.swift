//
//  MetadataModel.swift
//  BackgroundPlayerSwiftUI
//
//  Created by Александр Панин on 17.04.2022.
//

import Foundation

struct StaticMetadataModel {
    let assetURL: URL                   // MPNowPlayingInfoPropertyAssetURL
    let title: String                   // MPMediaItemPropertyTitle
    let artist: String                 // MPMediaItemPropertyArtist
}

struct DynamicMetadataModel {
    let rate: Float                     // MPNowPlayingInfoPropertyPlaybackRate
    let position: Float                 // MPNowPlayingInfoPropertyElapsedPlaybackTime
    let duration: Float                 // MPMediaItemPropertyPlaybackDuration
}
