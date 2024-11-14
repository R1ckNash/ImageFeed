//
//  URLSession+data.swift
//  ImageFeed
//
//  Created by Ilia Liasin on 10/11/2024.
//

import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidRequest
    case decodingError(Error)
}

extension URLSession {
    
    func data(for request: URLRequest,
              completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionTask {
        
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request) { data, response, error in
            
            if let error = error {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse else {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
                return
            }
            
            guard 200..<300 ~= response.statusCode else {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(response.statusCode)))
                return
            }
            
            fulfillCompletionOnTheMainThread(.success(data))
        }
        
        return task
    }
    
}
