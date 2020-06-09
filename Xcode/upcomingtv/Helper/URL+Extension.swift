//
//  URL+Extension.swift
//
//  Created by Daniel on 6/8/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

extension URL {

    func get<T: Codable>(debug: Bool = true, completion: @escaping (Result<T, NetError>) -> Void) {
        if debug {
            print("get: \(self.absoluteString)")
        }

        let session = URLSession.shared
        session.dataTask(with: self) { data, _, error in
            if error != nil {
                DispatchQueue.main.async {
                    completion(.failure(.session))
                }

                return
            }

            guard let unwrapped = data else {
                DispatchQueue.main.async {
                    completion(.failure(.data))
                }

                return
            }

            guard let result = try? JSONDecoder().decode(T.self, from: unwrapped) else {
                DispatchQueue.main.async {
                    completion(.failure(.json))
                }
                return
            }

            DispatchQueue.main.async {
                completion(.success(result))
            }
        }.resume()
    }

}

enum NetError: Error {

    case data
    case json
    case session

}
