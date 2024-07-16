//
//  MyCyprusRequest.swift
//  MyCyprus
//
//  Created by Egor Kruglov on 16.07.2024.
//

import Foundation

enum MyCyprusRequest {
    case getOrganizationWith(id: Int)
    case getAllOrganizations
    case addToFavorites(id: Int)
    case removeFromFavorites(id: Int)

    var httpMethod: String {
        switch self {
        case .getOrganizationWith:
            "GET"
        case .getAllOrganizations:
            "GET"
        case .addToFavorites:
            "POST"
        case .removeFromFavorites:
            "DELETE"
        }
    }

    var endpoint: String {
        switch self {
        case .getOrganizationWith(let id):
            "/internship/organization/\(id)/"
        case .getAllOrganizations:
            "/internship/organizations/category/1/organizations/"
        case .addToFavorites(let id), .removeFromFavorites(let id):
            "/internship/organization/\(id)/favorite/"
        }
    }
}
