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
            
            print("HTTP Response status code: \(response.statusCode)")
            
            guard 200..<300 ~= response.statusCode else {
                print("HTTP Error Code: \(response.statusCode)")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(response.statusCode)))
                return
            }
            
            fulfillCompletionOnTheMainThread(.success(data))
        }
        
        return task
    }
    
    func objectTask<T: Decodable>(for request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) -> URLSessionTask {
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let task = data(for: request) { (result: Result<Data, Error>) in
            
            switch result {
            case .success(let data):
                do {
                    print("Response data: \(String(data: data, encoding: .utf8) ?? "Invalid UTF-8 data")")
                    let body = try decoder.decode(T.self, from: data)
                    completion(.success(body))
                }
                catch {
                    print("Decoding error: \(error.localizedDescription), data: \(String(data: data, encoding: .utf8) ?? "")")
                    completion(.failure(NetworkError.decodingError(error)))
                }
                
            case .failure(let error):
                print("Network error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        return task
    }
    
}
