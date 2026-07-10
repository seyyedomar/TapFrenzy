//
//  ScoreBadge.swift
//  TapFrenzy
//
//  Created by Seyyed Omar on 2026-07-10.
//

import SwiftUI

struct ScoreBadge: View {
    let score: Int

    var body: some View {
        Text("\(score)")
            .font(.system(size: 60, weight: .bold, design: .rounded))
            .foregroundColor(.white)
    }
}

#Preview {
    ZStack {
        Color.indigo.ignoresSafeArea()
        ScoreBadge(score: 42)
    }
}

