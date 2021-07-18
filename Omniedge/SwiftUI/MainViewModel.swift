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
    
    init(config: OmniEdgeConfig) {
        self.config = config
        OmniEdgeManager.shared.statusDidChangeHandler = { [weak self] status in
            self?.status = status
        }
    }
    
    func handleStart() {
        config.sync()
        OmniEdgeManager.shared.start(with: config) { error in
        }
    }
    
    func handleStop() {
        OmniEdgeManager.shared.stop()
    }
    
    func handleRemove() {
        OmniEdgeManager.shared.remove { error in
        }
    }
}
