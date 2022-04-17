//
//  AudioFileDataManager.swift
//  BackgroundPlayerSwiftUI
//
//  Created by Александр Панин on 17.04.2022.
//

import Foundation

struct AudioFileDataManager {
    
   static var audioFilesModels: [AudioFileModel] {
        [
            AudioFileModel(metadata: StaticMetadataModel(title: "clarnet_comp_1")),
            AudioFileModel(metadata: StaticMetadataModel(title: "clarnet_comp_2")),
            AudioFileModel(metadata: StaticMetadataModel(title: "clarnet_comp_3")),
            AudioFileModel(metadata: StaticMetadataModel(title: "clarnet_comp_4"))
        ]
    }
}
