//
//  LXMuteDetector.swift
//  Demo
//
//  Created by 蒋理智 on 2020/1/2.
//  Copyright © 2020 SwiftKick Mobile. All rights reserved.
//

import UIKit
import AudioToolbox

class LXMuteDetector {
    
    var interval: TimeInterval = 0
    
    var soundId: SystemSoundID = UINT32_MAX
    
    var detectCompletion: ((Bool) -> Void)?
    
    
    let completionProc: AudioServicesSystemSoundCompletionProc = {
        (soundId: SystemSoundID, pointer: UnsafeMutableRawPointer?) in
        let elapsed = Date.timeIntervalSinceReferenceDate - LXMuteDetector.shareInstance.interval
        let isMute = (elapsed < 0.1)
        LXMuteDetector.shareInstance.detectCompletion?(isMute)
    }
    
    static let shareInstance = LXMuteDetector()
    
    private init() {
        
        if let url = Bundle.sm_frameworkBundle().url(forResource: "MuteDetector", withExtension: "mp3") {
            let statu = AudioServicesCreateSystemSoundID(url as CFURL, &self.soundId)
            if statu == kAudioServicesNoError {
                AudioServicesAddSystemSoundCompletion(self.soundId, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue, completionProc, nil)
                var yes: UInt32 = 1
                AudioServicesSetProperty(kAudioServicesPropertyIsUISound, self.soundId, &self.soundId, yes, &yes)
            }
        }
        
    }
    
    
    
    func detectComplete(_ complete: @escaping ((Bool) -> Void)) {
        self.interval = Date.timeIntervalSinceReferenceDate
        AudioServicesPlaySystemSound(self.soundId)
        self.detectCompletion = complete
    }
    
    class func playSyatemAlert(_ mute: Bool) {
        if mute {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        } else {
            AudioServicesPlaySystemSound(1312)
        }
    }
    
    deinit {
        if self.soundId != UINT32_MAX {
            AudioServicesRemoveSystemSoundCompletion(self.soundId)
            AudioServicesDisposeSystemSoundID(self.soundId)
        }
    }

}

