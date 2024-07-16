//
//  NetworkError.swift
//  MyCyprus
//
//  Created by Egor Kruglov on 16.07.2024.
//

import Foundation

enum NetworkError: Error {
    case invalidUrl
    case unknown
    case badResponse
    case decodingError
    case unexpectedStatusCode
    case handlingFavouriteFailed
}
