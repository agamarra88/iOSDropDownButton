//
//  RestAPI.swift
//  DropDownButton
//
//  Created by Arturo Gamarra on 7/5/20.
//  Copyright © 2020 Abstract. All rights reserved.
//

import Foundation

enum ResponseAPI<T> {
    case success(T)
    case failure(Error)
}

protocol RestAPI {
    
    func callService<T: Decodable>(atUrl urlString: String,
                                   verb: String,
                                   body: [String: Any]?,
                                   headers: [String: String]?,
                                   completion: @escaping (ResponseAPI<T>) -> Void)
}

extension RestAPI {
    
    // Closure es un funcion convertida en una variable.
    func callService<T: Decodable>(atUrl urlString: String,
                                   verb: String,
                                   body: [String: Any]? = nil,
                                   headers: [String: String]? = nil,
                                   completion: @escaping (ResponseAPI<T>) -> Void)  {
        
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers
        request.httpMethod = verb
        
        if let params = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        }
        
        let configuracion = URLSessionConfiguration.default
        let session = URLSession(configuration: configuracion)
        
        // Data Task --> Para subir o bajar DATOS
        let tarea = session.dataTask(with: request) { (data, response, error) in
            if let anError = error {
                OperationQueue.main.addOperation {
                    completion(.failure(anError))
                }
                return
            }
            
            // Me conecte con el server y analizo la respuesta
            guard let httpResponse = response as? HTTPURLResponse
                , let myData = data
                , httpResponse.statusCode >= 200 && httpResponse.statusCode <= 299 else {
                    OperationQueue.main.addOperation {
                        completion(.failure(self.createError(withText: "Error en la respuesta del web service")))
                    }
                    return
            }
            
            // Convertir la respuesta en un JSON
            do {
                let dto = try JSONDecoder().decode(T.self, from: myData)
                OperationQueue.main.addOperation {
                    completion(.success(dto))
                }
                
            } catch(let ex) {
                OperationQueue.main.addOperation {
                    completion(.failure(ex))
                }
            }
        }
        tarea.resume()
    }
    
    private func createError(withText text: String) -> Error {
        return NSError(domain: "", code: -9999, userInfo: [NSLocalizedDescriptionKey: text])
    }
}
