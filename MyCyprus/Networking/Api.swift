//
//  Api.swift
//  MyCyprus
//
//  Created by Egor Kruglov on 16.07.2024.
//

import Foundation

final class MyCyprusApi {

    // MARK: - dependencies

    var baseUrl: String
    var token: String

    // MARK: - initializer

    init(
        baseUrl: String = "https://api.mycyprus.app/api",
        // swiftlint:disable:next line_length
        token: String = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTU3LCJleHAiOjE3MjIwMDE3NjJ9.BrjO9Pf4K28nB1-fSEMkHLKAjzldXb_U36aCRnvYojg"
    ) {
        self.baseUrl = baseUrl
        self.token = token
    }

    // MARK: - public funcs

    func getOrganizationWith(id: Int) async throws -> OrganizationInfo {
        do {
            let result: OrganizationInfo = try await sendRequest(.getOrganizationWith(id: id))
            return result
        } catch {
            throw error
        }
    }
    func getAllOrganizations() async throws -> [Organization] {
        do {
            let result: OrganizationsPage = try await sendRequest(.getAllOrganizations)
            return result.data
        } catch {
            throw error
        }
    }

    func markOrganizationWith(id: Int, asLiked: Bool) async throws {
        do {
            let request = asLiked ? MyCyprusRequest.addToFavorites(id: id) : MyCyprusRequest.removeFromFavorites(id: id)
            try await sendRequest(request)
        } catch {
            throw error
        }
    }

    // MARK: - private funcs

    private func sendRequest<Model: Codable>(_ request: MyCyprusRequest) async throws -> Model {
        let data = try await sendRequest(request)
        do {
            let decodedResponse = try JSONDecoder().decode(Model.self, from: data)
            return decodedResponse
        } catch {
            throw NetworkError.decodingError
        }
    }

    @discardableResult
    private func sendRequest(_ request: MyCyprusRequest) async throws -> Data {
        guard let url = URL(string: baseUrl + request.endpoint) else { throw NetworkError.invalidUrl }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.httpMethod
        urlRequest.setValue("Token \(token)", forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            guard let response = response as? HTTPURLResponse else { throw NetworkError.badResponse }
            guard (200...299).contains(response.statusCode) else { throw NetworkError.unexpectedStatusCode }
            return data
        } catch {
            throw error
        }
    }
}
