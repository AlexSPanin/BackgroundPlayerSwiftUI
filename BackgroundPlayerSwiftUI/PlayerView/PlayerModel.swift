//
//  PlayerModel.swift
//  BackgroundPlayerSwiftUI
//
//  Created by Александр Панин on 17.04.2022.
//

import Foundation


struct ButtonPlayer: Hashable {
    
    let type: PlayerCommand
    var name: String
    
    init(type: PlayerCommand, name: String) {
        self.type = type
        self.name = name
    }
    
    mutating func changeName(to name: String) {
        self.name = name
    }
}

struct PlayerModel: Hashable {
    var title = ""
    var passedTime: Float = 0.0
    var leftTime: Float = 0.0
    var seekTime: Float = 0.0
    var buttons: [ButtonPlayer]
    
    init(buttons: [ButtonPlayer]) {
        self.buttons = buttons
    }
}
