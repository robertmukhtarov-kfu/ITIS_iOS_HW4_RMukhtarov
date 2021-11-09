//
//  URL+Extensions.swift
//  hw4
//
//  Created by Robert Mukhtarov on 09.11.2021.
//

import Foundation

extension URL {
    static let catsURL: URL = {
        guard let url = URL(string: "https://catfact.ninja/fact") else {
            fatalError("Invalid cats URL")
        }
        return url
    }()

    static let dogsURL: URL = {
        guard let url = URL(string: "https://dog.ceo/api/breeds/image/random") else {
            fatalError("Invalid dogs URL")
        }
        return url
    }()
}
