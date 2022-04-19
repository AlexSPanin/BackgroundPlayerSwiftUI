//
//  PlayerCommand.swift
//  BackgroundPlayerSwiftUI
//
//  Created by Александр Панин on 17.04.2022.
//

import Foundation
import MediaPlayer


enum PlayerCommand: CaseIterable {
    case back, togglePausePlay, stop, forward, changePlaybackPosition
    
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
        case .changePlaybackPosition:
            return remoteCommandCenter.changePlaybackPositionCommand
        }
    }
    
    func removeHandler() {
        remoteCommand.removeTarget(nil)
    }
    
    func addHandler(_ handler: @escaping (PlayerCommand, MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus) {
        remoteCommand.addTarget { handler(self, $0) }
    }
    
    func setEnabled(_ isEnabled: Bool) {
        remoteCommand.isEnabled = isEnabled
    }
}


