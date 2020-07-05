//
//  Restaurante.swift
//  Arquitectura
//
//  Created by Arturo Gamarra on 4/13/19.
//  Copyright © 2019 Academia Moviles. All rights reserved.
//

import DropDown

struct Movie: Codable, DropDownItemable {
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case detail = "overview"
        case posterPath = "poster_path"
        case rate = "vote_average"
        case votes = "vote_count"
    }
    
    // MARK: - Propiedades
    var id: Int = 0
    var title: String = ""
    var detail: String = ""
    var posterPath: String?
    var rate: Double = 0
    var votes: Int = 0
    
    var imageURL: URL? {
        guard let path = posterPath else { return nil }
        let imageURLString = "https://image.tmdb.org/t/p/w500\(path)"
        return URL(string: imageURLString)
    }
    
    // MARK: - DropDownItemable
    var description: String {
        return title
    }

    func isEqual(to other: DropDownItemable) -> Bool {
        guard let movie = other as? Movie else { return false }
        return id == movie.id
    }
}
