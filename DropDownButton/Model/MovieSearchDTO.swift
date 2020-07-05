//
//  SearchMovieDTO.swift
//  DropDownButton
//
//  Created by Arturo Gamarra on 7/5/20.
//  Copyright © 2020 Abstract. All rights reserved.
//

import Foundation

struct MovieSearchDTO: Codable {
    
    enum CodingKeys: String, CodingKey {
        case page = "page"
        case results = "results"
        case totalCount = "total_results"
        case totalPages = "total_pages"
    }
    
    var page: Int = 0
    var results: [Movie] = []
    var totalCount: Int = 0
    var totalPages: Int = 0
    
}
