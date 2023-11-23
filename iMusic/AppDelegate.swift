//
//  AppDelegate.swift
//  iMusic
//
//  Created by yfm on 2023/11/17.
//

import UIKit
import KafkaRefresh
import AVFoundation
import NotificationCenter
import MediaPlayer

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true)
        UIApplication.shared.beginReceivingRemoteControlEvents()
        createRemoteCommandCenter()
        
        configRefreshStyle()
        addNoti()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

extension AppDelegate {
    func configRefreshStyle() {
        KafkaRefreshDefaults.standard()?.headDefaultStyle = .replicatorWoody
        KafkaRefreshDefaults.standard()?.footDefaultStyle = .replicatorWoody
        KafkaRefreshDefaults.standard()?.themeColor = .red
    }
}

// MARK: - 中断处理
extension AppDelegate {
    func addNoti() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleAudioSessionInterruption(_:)), name: AVAudioSession.interruptionNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleMediaServicesReset(_:)), name: AVAudioSession.mediaServicesWereResetNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleMediaServicesLost(_:)), name: AVAudioSession.mediaServicesWereLostNotification, object: nil)
    }
    
    @objc func handleAudioSessionInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let interruptionType = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt else {
                return
        }
        
        if interruptionType == AVAudioSession.InterruptionType.began.rawValue {
            // 处理音频会话中断开始的情况
            // 暂停播放、保存播放状态等
            AudioPlayer.shared.pause()
        } else if interruptionType == AVAudioSession.InterruptionType.ended.rawValue {
            if let options = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt,
                options == AVAudioSession.InterruptionOptions.shouldResume.rawValue {
                // 处理音频会话中断结束的情况
                // 恢复播放、恢复播放状态等
                AudioPlayer.shared.play()
            }
        }
    }

    @objc func handleMediaServicesReset(_ notification: Notification) {
        // 处理来电开始的情况
        AudioPlayer.shared.pause()
    }

    @objc func handleMediaServicesLost(_ notification: Notification) {
        // 处理来电结束的情况
        AudioPlayer.shared.play()
    }
}

extension AppDelegate {
//    override func remoteControlReceived(with event: UIEvent?) {
//        if event?.type == .remoteControl {
//            switch event?.subtype {
//            case .remoteControlPlay:
//                AudioPlayer.shared.play()
//            case .remoteControlPause:
//                AudioPlayer.shared.pause()
//            case .remoteControlTogglePlayPause:
//                AudioPlayer.shared.playOrPause()
//            case .remoteControlNextTrack:
//                AudioPlayer.shared.playNext()
//            case .remoteControlPreviousTrack:
//                AudioPlayer.shared.playPrevious()
//            case .remoteControlBeginSeekingForward:
//                print("BeginSeekingForward")
//            case .remoteControlEndSeekingForward:
//                print("EndSeekingForward")
//            case .remoteControlBeginSeekingBackward:
//                print("BeginSeekingBackward")
//            case .remoteControlEndSeekingBackward:
//                print("EndSeekingBackward")
//            default:
//                break
//            }
//        }
//    }
    
    func createRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.addTarget { _ in
            AudioPlayer.shared.play()
            return .success
        }
        commandCenter.pauseCommand.addTarget { _ in
            AudioPlayer.shared.pause()
            return .success
        }
        commandCenter.togglePlayPauseCommand.addTarget { _ in
            AudioPlayer.shared.playOrPause()
            return .success
        }
        commandCenter.nextTrackCommand.addTarget { _ in
            AudioPlayer.shared.playNext()
            return .success
        }
        commandCenter.previousTrackCommand.addTarget { _ in
            AudioPlayer.shared.playPrevious()
            return .success
        }
        commandCenter.changePlaybackPositionCommand.addTarget { event in
            if let positionEvent = event as? MPChangePlaybackPositionCommandEvent {
                let totalTime = Double(AudioPlayer.shared.curSong.timelength) / 1000.0
                let position = Float(positionEvent.positionTime / totalTime)
                AudioPlayer.shared.seek(position: position)
            }
            return .success
        }
    }
}
