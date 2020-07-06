//
//  MovieService.swift
//  Arquitectura
//
//  Created by Arturo Gamarra on 4/13/19.
//  Copyright © 2019 Academia Moviles. All rights reserved.
//

import Foundation

struct MovieService: RestAPI {
    
    private var urlBase = "https://api.themoviedb.org/3/"
    private var apiKey = "d4f9821896bf26da9c7eb377ed0fe748"
    
    func search(by text:String,
                in page:Int,
                completion: @escaping (ResponseAPI<MovieSearchDTO>) -> Void) {
        
        var url = "\(urlBase)search/movie?api_key=\(apiKey)&page=\(page)&include_adult=false"
        if !text.isEmpty {
            url += "&query=\(text)"
        }
        url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? url
        callService(atUrl: url, verb: "GET", completion: completion)
    }
    
}
