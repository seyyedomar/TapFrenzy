//
//  GameMode.swift
//  TapFrenzy
//
//  Created by Seyyed Omar on 2026-07-09.
//
//  Identifies which of the 3 games a GameSession belongs to.
//

import Foundation

enum GameMode: String, Codable, CaseIterable, Identifiable {
    case tapFrenzy
    case lightItUp
    case quizRush

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .tapFrenzy: return "Tap Frenzy"
        case .lightItUp: return "Light It Up"
        case .quizRush: return "Quiz Rush"
        }
    }

    var symbolName: String {
        switch self {
        case .tapFrenzy: return "hand.tap"
        case .lightItUp: return "bolt.fill"
        case .quizRush: return "questionmark.circle"
        }
    }
}

