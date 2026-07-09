//
//  TriviaService.swift
//  TapFrenzy
//
//  Created by Seyyed Omar on 2026-07-08.
//

//URL and fetch/decode logic in one place,


import Foundation

struct TriviaService {

    enum ServiceError: Error {
        case invalidURL
        case invalidResponse
        case decodingFailed
    }

    private let urlString = "https://opentdb.com/api.php?amount=10&type=multiple"

    func fetchQuestions() async throws -> [TriviaQuestion] {
        guard let url = URL(string: urlString) else {
            throw ServiceError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ServiceError.invalidResponse
        }

        do {
            let decoded = try JSONDecoder().decode(TriviaResponse.self, from: data)
            return decoded.results
        } catch {
            throw ServiceError.decodingFailed
        }
    }
}
