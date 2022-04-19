//
//  PlayerViewModel.swift
//  BackgroundPlayerSwiftUI
//
//  Created by Александр Панин on 17.04.2022.
//

import AVFoundation
import MediaPlayer

//class AppDelegate: NSObject, UIApplicationDelegate {
//
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//        application.beginReceivingRemoteControlEvents()
//        return true
//
//    }
//}

class  PlayerViewModel: ObservableObject {
    
    @Published var playerModel: PlayerModel!
    @Published var indexAudioFile: Int
    let audioFilesModels: [AudioFileModel]
    let maxIndexAudioFile: Int
    
    
    private var sessionObserver: NSObjectProtocol!
    //    private var isEmptyAudioFile: Bool
    private var isPlaying = false
    {
        didSet
        {
            settingPlayerButtons()
        }
    }
    
    private var needsScheduled = true
    private var audioEngine = AVAudioEngine()
    private var audioPlayerNode = AVAudioPlayerNode()
    private var audioFile = AVAudioFile()
    
    init() {
        self.audioFilesModels = AudioFileDataManager.audioFilesModels
        self.maxIndexAudioFile = audioFilesModels.count - 1
        self.indexAudioFile = 0
        if !self.audioFilesModels.isEmpty { prepareAudioFile(audioFileModel: audioFilesModels[indexAudioFile])}
        settingPlayerButtons()
        
        prepareAudioFile(audioFileModel: audioFilesModels[indexAudioFile])
        prepareEngine()
        
        do {
            try setupObservel()
            try setupRemoteComande(commandHandler: setupPlayerCommand(command:event:))
        }
        catch {
            print("ERROR setupRemoteComande")
        }
        //      handlePlaybackChange()
    }
    
    func setupRemoteComande(commandHandler: @escaping (PlayerCommand, MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus) throws {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        for command in PlayerCommand.allCases {
            command.setEnabled(true)
            command.addHandler (commandHandler)
        }
        PlayerMetadataManager.setStaticMetadata(audioFilesModels[indexAudioFile].metadata)
    }
    
    func setupPlayerCommand(command: PlayerCommand, event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        switch  command {
        case .back:
            backButton()
            PlayerMetadataManager.setStaticMetadata(audioFilesModels[indexAudioFile].metadata)
        case .togglePausePlay:
            playPauseButton()
        case .stop:
            stopButton()
        case .forward:
            forwardButton()
            PlayerMetadataManager.setStaticMetadata(audioFilesModels[indexAudioFile].metadata)
        }
        return .success
    }
    
    func handlePlaybackChange() {
        let rate = audioPlayerNode.rate
        guard let nodeTime = audioPlayerNode.lastRenderTime else { return }
        guard let playerTime = audioPlayerNode.playerTime(forNodeTime: nodeTime) else { return }
        let position = Float(playerTime.sampleTime) / Float(playerTime.sampleRate)
        let duration = Float(audioFile.length) / Float(audioFile.fileFormat.sampleRate) - position
        
        let metadata = DynamicMetadataModel(rate: rate,
                                            position: position,
                                            duration: duration)
        PlayerMetadataManager.setDinamicMetadata(metadata)
        
    }
    
    func setupObservel() throws {
        
        let audioSession = AVAudioSession.sharedInstance()
        
        // Observe interruptions to the audio session.
        
        sessionObserver = NotificationCenter.default.addObserver(forName: AVAudioSession.interruptionNotification, object: audioSession, queue: .current) {
            [unowned self] notification in
            self.handleAudioSessionInterruption(notification: notification)
            print("Notification \(notification)")
        }
        setupAudioSession()
        startEngine()
    }
    
    private func handleAudioSessionInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let interruptionTypeUInt = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let interruptionType = AVAudioSession.InterruptionType(rawValue: interruptionTypeUInt) else { return }
        
        switch interruptionType {
            
        case .began:
            
            // When an interruption begins, just invoke the handler.
            
            print("Began \(userInfo)")
            
        case .ended:
            
            // When an interruption ends, determine whether playback should resume
            // automatically, and reactivate the audio session if necessary.
            
            do {
                
                try AVAudioSession.sharedInstance().setActive(true)
                
                if let optionsUInt = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt,
                   AVAudioSession.InterruptionOptions(rawValue: optionsUInt).contains(.shouldResume) {
                }
                
                print("Ended \(userInfo)")
            }
            
            // When the audio session cannot be resumed after an interruption,
            // invoke the handler with error information.
            
            catch {
                print("Catch \(userInfo)")
            }
            
        @unknown default:
            break
        }
    }
    
}
//MARK: - PlayerButtons
extension PlayerViewModel {
    
    func pressPlayerButtons(command: PlayerCommand) {
        switch  command {
        case .back:
            backButton()
        case .togglePausePlay:
            playPauseButton()
        case .stop:
            stopButton()
        case .forward:
            forwardButton()
        }
    }
    
    private func settingPlayerButtons() {
        playerModel = PlayerModel(buttons: [
            ButtonPlayer(type: .back, name: "backward"),
            ButtonPlayer(type: .stop, name: "stop"),
            ButtonPlayer(type: .togglePausePlay, name: isPlaying ? "pause" : "play"),
            ButtonPlayer(type: .forward, name: "forward")
        ])
    }
    
    private func playPauseButton() {
        
        switch isPlaying {
            
        case true:
            isPlaying.toggle()
            audioPlayerNode.pause()
            audioEngine.pause()
            //         closeAudioSession()
        case false:
            isPlaying.toggle()
            //         setupAudioSession()
            startEngine()
            if needsScheduled { scheduleAudioFile() }
            audioPlayerNode.play()
        }
    }
    
    private func stopButton() {
        audioPlayerNode.stop()
        audioEngine.stop()
        //       closeAudioSession()
        isPlaying = false
        needsScheduled = true
    }
    
    private func backButton() {
        if indexAudioFile != 0 {
            let wasPlaing = isPlaying
            if isPlaying { stopButton() }
            indexAudioFile -= 1
            audioEngine.reset()
            prepareAudioFile(audioFileModel: audioFilesModels[indexAudioFile])
            prepareEngine()
            needsScheduled = true
            if wasPlaing { playPauseButton() }
        }
    }
    
    private func forwardButton() {
        if indexAudioFile < maxIndexAudioFile {
            let wasPlaing = isPlaying
            if isPlaying { stopButton() }
            indexAudioFile += 1
            audioEngine.reset()
            prepareAudioFile(audioFileModel: audioFilesModels[indexAudioFile])
            prepareEngine()
            needsScheduled = true
            if wasPlaing { playPauseButton() }
        }
    }
}

//MARK: - AudioFile
extension PlayerViewModel {
    
    private  func prepareAudioFile(audioFileModel: AudioFileModel) {
        
        do {
            audioFile = try AVAudioFile(forReading: audioFileModel.url)
        } catch {
            print("ERROR prepare Audio File")
        }
    }
    
    private func scheduleAudioFile() {
        audioPlayerNode.scheduleFile(audioFile, at: nil)
        needsScheduled = false
    }
}

//MARK: - AudioEngine
extension PlayerViewModel {
    
    private func startEngine() {
        do {
            try audioEngine.start()
        } catch {
            print("ERROR start Engine")
        }
    }
    
    private func prepareEngine() {
        audioEngine.attach(audioPlayerNode)
        audioEngine.connect(audioPlayerNode, to: audioEngine.mainMixerNode , format: audioFile.processingFormat)
        audioEngine.prepare()
    }
}

//MARK: - AudioSession
extension PlayerViewModel {
    
    private func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback,
                                    mode: .default)
        }
        catch {
            print("ERROR Playback Session")
        }
        do {
            try session.setActive(true)
        } catch {
            print("ERROR Active Audio Session")
        }
    }
    
    private func closeAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setActive(false)
        } catch {
            print("ERROR Close Audio Session")
        }
    }
}


