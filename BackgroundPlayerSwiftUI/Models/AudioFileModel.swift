//
//  AudioFileModel.swift
//  BackgroundPlayerSwiftUI
//
//  Created by Александр Панин on 17.04.2022.
//

import Foundation
import AVFoundation

struct AudioFileModel {
    
    let url: URL
    let metadata: StaticMetadataModel
    
    init(metadata: StaticMetadataModel) {
        self.metadata = metadata
        self.url = URL(string: metadata.urlString)!
    }
}
