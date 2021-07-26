//
//  MainViewModel.swift
//  Omniedge
//
//  Created by samuelsong(samuel.song.bc@gmail.com) on 2021/6/20.
//  
//

import Foundation
import OmniedgeDylib

final class MainViewModel: ObservableObject {
    @Published var config: OmniEdgeConfig
    @Published var status = OmniEdgeManager.Status.off
    @Published var showAlert = false
    
    init(config: OmniEdgeConfig) {
        self.config = config
        OmniEdgeManager.shared.statusDidChangeHandler = { [weak self] status in
            self?.status = status
        }
    }
    
    func handleStart() {
        OmniEdgeManager.shared.start(with: config) { error in
        }
    }
    
    func handleStop() {
        OmniEdgeManager.shared.stop()
    }
    
    func handleRemove() {
        OmniEdgeManager.shared.removeFromPreferences { error in
            if error != nil {
                self.showAlert = true
            } else {
                self.showAlert = false
            }
        }
    }
}
