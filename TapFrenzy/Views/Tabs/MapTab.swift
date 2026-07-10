//
//  MapTab.swift
//  TapFrenzy
//
//  Created by Seyyed Omar on 2026-07-10.
//  Shows a pin for every completed GameSession. Tapping a pin shows
//  that session's mode, score, and when it happened.
//

import SwiftUI
import MapKit

struct MapTab: View {
    @ObservedObject private var store = GameSessionStore.shared
    @ObservedObject private var locationService = LocationService.shared
    @State private var selectedSession: GameSession?
    @State private var cameraPosition: MapCameraPosition = .automatic

    var body: some View {
        NavigationStack {
            Map(position: $cameraPosition) {
                ForEach(store.sessions) { session in
                    Annotation(session.mode.displayName, coordinate: session.coordinate) {
                        Button {
                            selectedSession = session
                        } label: {
                            Image(systemName: "mappin.circle.fill")
                                .font(.title2)
                                .foregroundStyle(color(for: session.mode))
                                .background(Circle().fill(.white).padding(2))
                        }
                    }
                }
            }
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                            locationService.requestPermission()
                            if let coordinate = store.sessions.last?.coordinate {
                                cameraPosition = .region(
                                    MKCoordinateRegion(
                                        center: coordinate,
                                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                    )
                                )
                            }
                        }
            .sheet(item: $selectedSession) { session in
                sessionDetail(session)
                    .presentationDetents([.fraction(0.3)])
            }
        }
    }

    private func sessionDetail(_ session: GameSession) -> some View {
        VStack(spacing: 12) {
            Image(systemName: session.mode.symbolName)
                .font(.largeTitle)
                .foregroundStyle(color(for: session.mode))
            Text(session.mode.displayName)
                .font(.title2.bold())
            Text("Score: \(session.score)")
                .font(.title3)
            Text(session.timestamp, style: .date)
                .foregroundColor(.secondary)
        }
        .padding()
    }

    private func color(for mode: GameMode) -> Color {
        switch mode {
        case .tapFrenzy: return .indigo
        case .lightItUp: return .orange
        case .quizRush: return .green
        }
    }
}

#Preview {
    MapTab()
}
