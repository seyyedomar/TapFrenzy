//
//  GameLevel.swift
//  TapFrenzy
//
//  Created by Seyyed Omar on 2026-07-08.
//

import SwiftUI

enum GameLevel: Int, CaseIterable {
    case one = 1
    case two
    case three
    case four

    var cardCount: Int {
        switch self {
        case .one: return 3
        case .two: return 4
        case .three: return 6
        case .four: return 9
        }
    }

    var columns: Int {
        switch self {
        case .one: return 3
        case .two: return 4
        case .three: return 3
        case .four: return 3
        }
    }

    var litWindow: Double {
        switch self {
        case .one: return 1.5
        case .two: return 1.2
        case .three: return 1.0
        case .four: return 0.8
        }
    }

    var simultaneousLitCount: Int {
        self == .four ? 2 : 1
    }

    var glowColor: Color {
        switch self {
        case .one: return .green
        case .two: return .cyan
        case .three: return .orange
        case .four: return .red
        }
    }

    var startTime: Double {
        switch self {
        case .one: return 0
        case .two: return 15
        case .three: return 30
        case .four: return 45
        }
    }

    static func level(forElapsed elapsed: Double) -> GameLevel {
        if elapsed >= GameLevel.four.startTime { return .four }
        if elapsed >= GameLevel.three.startTime { return .three }
        if elapsed >= GameLevel.two.startTime { return .two }
        return .one
    }
}
