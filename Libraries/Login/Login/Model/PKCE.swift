//
//  PKCE.swift
//  Login
//
//  Created by Antigravity on 2026/01/09.
//

import Foundation
import CryptoKit

struct PKCEInfo {
    let verifier: String
    let challenge: String
    let state: String
}

struct PKCE {
    static func generate() -> PKCEInfo {
        let state = randomString(length: 32)
        let verifier = randomString(length: 64)
        
        let challenge = generateChallenge(from: verifier)
        
        return PKCEInfo(verifier: verifier, challenge: challenge, state: state)
    }
    
    private static func randomString(length: Int) -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~"
        return String((0..<length).map { _ in characters.randomElement()! })
    }
    
    private static func generateChallenge(from verifier: String) -> String {
        guard let data = verifier.data(using: .utf8) else { return "" }
        let hash = SHA256.hash(data: data)
        return Data(hash).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
