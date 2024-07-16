//
//  Models.swift
//  MyCyprus
//
//  Created by Egor Kruglov on 16.07.2024.
//

import Foundation

// MARK: - OrganizationsPage
struct OrganizationsPage: Codable {
    let data: [Organization]
}

// MARK: - Organization
struct Organization: Codable, Hashable {
    let id: Int
    let name: String
    let photo: String
    let rate: Int?
    let averageCheck: [Int]
    let cuisines: [String]
    let isFavorite: Bool
}

// MARK: - OrganizationInfo
struct OrganizationInfo: Codable {
    let id: Int
    let name: String
    let detailedInfo: String?
    let photos: [String]
    let rate: Int?
    let distance: Double?
    let isFavorite: Bool
}
