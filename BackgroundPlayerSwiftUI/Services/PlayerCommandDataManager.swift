//
//  PlayerCommandDataManager.swift
//  BackgroundPlayerSwiftUI
//
//  Created by Александр Панин on 17.04.2022.
//

import Foundation
import MediaPlayer


enum PlayerCommand: CaseIterable {
    case back, togglePausePlay, stop, forward
    
    var remoteCommand: MPRemoteCommand {
        
        let remoteCommandCenter = MPRemoteCommandCenter.shared()
        
        switch self {
            
        case .togglePausePlay:
            return remoteCommandCenter.togglePlayPauseCommand
        case .stop:
            return remoteCommandCenter.stopCommand
        case .forward:
            return remoteCommandCenter.nextTrackCommand
        case .back:
            return remoteCommandCenter.previousTrackCommand
        }
    }
    
    func removeHandler() {
        remoteCommand.removeTarget(nil)
    }
    
    func setDisabled(_ isDisabled: Bool) {
        remoteCommand.isEnabled = !isDisabled
    }
}


