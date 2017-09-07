//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by SoSucesso on 07/09/17.
//  Copyright © 2017 Leonardo Simas. All rights reserved.
//

import MapKit


class FlickrClient {
    
    private static var shared : FlickrClient?
    
    static func sharedInstance() -> FlickrClient {
        if shared == nil {
            shared = FlickrClient()
        }
        return shared!
    }
    
    private init() {
    }
    
    private func createBasicUrl(parameters : [String:AnyObject]) -> URLComponents {
        var c = URLComponents()
        c.scheme = Constants.Flickr.APIScheme
        c.host = Constants.Flickr.APIHost
        c.path = Constants.Flickr.APIPath
        c.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            c.queryItems!.append(queryItem)
        }
        
        return c
    }
    
    private func createBasicParams() -> [String:String] {
        return [
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
        ]
    }
    
    private func parseJSON(data : Data?) -> [String:AnyObject?]? {
        guard let data = data else {
            return nil
        }
        
        do {
            return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
        } catch {
            return nil
        }
    }
    
    private func requestPhotos( coordinate : CLLocationCoordinate2D, page : Int?, completion : @escaping (([String : AnyObject?]?, String?) -> Void) ) {
        
        var params = createBasicParams()
        params[Constants.FlickrParameterKeys.Method] = Constants.FlickrParameterValues.SearchMethod
        params[Constants.FlickrParameterKeys.SafeSearch] = Constants.FlickrParameterValues.UseSafeSearch
        params[Constants.FlickrParameterKeys.Extras] = Constants.FlickrParameterValues.MediumURL
        params[Constants.FlickrParameterKeys.PerPage] = Constants.FlickrParameterValues.PerPage
        
        if page != nil {
            params[Constants.FlickrParameterKeys.Page] = String(page!)
        }
        
        let components = createBasicUrl(parameters: params as [String : AnyObject])
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                completion(nil, error?.localizedDescription)
                return
            }
            
            guard let json = self.parseJSON(data: data) else {
                completion(nil, Constants.ErrorMessages.ParseJson)
                return
            }
            
            guard let status = json[Constants.FlickrResponseKeys.Status] as? String, status == Constants.FlickrResponseValues.OKStatus else {
                completion(nil, json[Constants.FlickrResponseKeys.Message] as? String)
                return
            }
            
            guard let photosObj = json[Constants.FlickrResponseKeys.Photos] as? [String : AnyObject?] else {
                completion(nil, Constants.ErrorMessages.ParseJson)
                return
            }
            
            completion(photosObj, nil)
        }
    }
    
    func requestTotalPages( coordinate : CLLocationCoordinate2D, completion : @escaping ((Int?, String?) -> Void)) {
        requestPhotos(coordinate: coordinate, page : nil) { (photosObj, errorMessage) in
            if errorMessage != nil {
                completion(nil, errorMessage)
                return
            }
            
            guard let totalPages = photosObj?[Constants.FlickrResponseKeys.Photo] as? Int else {
                completion(nil, Constants.ErrorMessages.ParseJson)
                return
            }
            
            
            completion(totalPages, nil)
        }
    }
    
    func requestPhotosFor(coordinate : CLLocationCoordinate2D, completion : @escaping (([[String : AnyObject?]]?, String?) -> Void)) {
        
        requestTotalPages(coordinate: coordinate) { (totalPages, errorMessage) in
            if errorMessage != nil {
                completion(nil, errorMessage)
                return
            }
            
            let selectedPage = Int(arc4random_uniform(UInt32(totalPages!)) + 1)
            
            self.requestPhotos(coordinate: coordinate, page: selectedPage) { (photosObj, errorMessage) in
                if errorMessage != nil {
                    completion(nil, errorMessage)
                    return
                }
                
                guard let photos = photosObj?[Constants.FlickrResponseKeys.Photos] as? [[String : AnyObject?]] else {
                    completion(nil, Constants.ErrorMessages.ParseJson)
                    return
                }
                
                completion(photos, nil)
            }
        }
    }
    
}
