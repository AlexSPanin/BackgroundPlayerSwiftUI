//
//  TimeManager.swift
//  BackgroundPlayerSwiftUI
//
//  Created by Александр Панин on 17.04.2022.
//

import Foundation

extension DateComponentsFormatter {
    static let audioTime: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        
        return formatter
    }()
}

struct TimeManager {
    
    static func timeFormated(to time: Double) -> String {
        DateComponentsFormatter.audioTime.string(from: time) ?? "00:00"
    }
}


