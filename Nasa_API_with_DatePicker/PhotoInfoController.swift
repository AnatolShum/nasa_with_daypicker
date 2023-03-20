//
//  PhotoInfoController.swift
//  Nasa_API_with_DatePicker
//
//  Created by Anatolii Shumov on 24/02/2023.
//

import Foundation
import UIKit

protocol DateDelegate: AnyObject {
    func catchADay()
}

class PhotoInfoController {
    
    weak var delegate: DateDelegate?
    
    var selectedDate: String = ""
    
    enum PhotoInfoErrors: Error, LocalizedError {
        case itemNotFound
        case imageDataMissing
    }
    
    func fetchImage(from url: URL) async throws -> UIImage {
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        urlComponents?.scheme = "https"
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else { throw PhotoInfoErrors.imageDataMissing }
        
        guard let image = UIImage(data: data) else { throw PhotoInfoErrors.imageDataMissing }
        
        return image
    }
    
    
    func fetchPhotoInfo() async throws -> PhotoInfo {
        delegate?.catchADay()
        var urlComponents = URLComponents(string: "https://api.nasa.gov/planetary/apod")!
        urlComponents.queryItems = [
            "api_key": "DEMO_KEY",
            "date": "\(selectedDate)"
        ].map { URLQueryItem(name: $0.key, value: $0.value) }
    
            let (data, response) = try await URLSession.shared.data(from: urlComponents.url!)
    
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else { throw PhotoInfoErrors.itemNotFound }
    
            let jsonDecode = JSONDecoder()
            let photoInfo = try jsonDecode.decode(PhotoInfo.self, from: data)
            return(photoInfo)
    }
    
}



