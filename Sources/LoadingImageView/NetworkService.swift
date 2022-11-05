//
//  NetworkService.swift
//  
//
//  Created by Daniil Alferov on 05.11.2022.
//

import Foundation

struct LoaderError: Error {
    let title: String
    let code: Int
    
    init(title: String, code: Int = 0) {
        self.title = title
        self.code = code
    }
}

protocol NetworkService {
    @available(iOS 13.0.0, *)
    func loadData(url: URL) async -> Result<Data, LoaderError>
    func loadData(url: URL, success: @escaping (Data) -> Void, failure: ((LoaderError) -> Void)?)
}

struct NetworkServiceImp: NetworkService {
    
    @available(iOS 13.0.0, *)
    func loadData(url: URL) async -> Result<Data, LoaderError> {
        let request = URLRequest(url: url)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        do {
            let (data, response) = try await session.data(for: request)
            if let httpResponse = response as? HTTPURLResponse,
               !(200...299).contains(httpResponse.statusCode) {
                return .failure(LoaderError(title: "Unexpected response code: \(httpResponse.statusCode)"))
            }
            return .success(data)
        } catch (let error) {
            return .failure(LoaderError(title: error.localizedDescription))
        }
    }
    
    func loadData(url: URL, success: @escaping (Data) -> Void, failure: ((LoaderError) -> Void)? = nil) {
        let request = URLRequest(url: url)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        session.dataTask(with: request) { data, response, error in
            var responseCode = 0
            if let httpResponse = response as? HTTPURLResponse {
                responseCode = httpResponse.statusCode
            }
            
            if !(200...299).contains(responseCode) {
                failure?(LoaderError(title: "Unexpected response code: \(responseCode)"))
                return
            }
            
            if let error = error {
                failure?(LoaderError(title: error.localizedDescription, code: responseCode))
                return
            }
            
            guard let data = data else {
                failure?(LoaderError(title: "Data is nil"))
                return
            }

            success(data)
        }
    }
    
    
}
