//
//  MyCyprusNetworker.swift
//  MyCyprus
//
//  Created by Egor Kruglov on 16.07.2024.
//

import Foundation

final class MyCyprusNetworker {

    private let api: MyCyprusApi

    init(api: MyCyprusApi) {
        self.api = api
    }

    func loadOrganizations() async throws -> [Organization] {
        do {
            return try await api.getAllOrganizations()
        } catch {
            throw error
        }
    }

    func didTapLikeOrganizationWith(id: Int, oldStatus: Bool) async throws {
        do {
            try await api.markOrganizationWith(id: id, asLiked: !oldStatus)
        } catch {
            throw NetworkError.handlingFavouriteFailed
        }
    }

    func loadOrganizationInfoWithId(_ id: Int) async throws -> OrganizationInfo {
        do {
            return try await api.getOrganizationWith(id: id)
        } catch {
            throw error
        }
    }
}
