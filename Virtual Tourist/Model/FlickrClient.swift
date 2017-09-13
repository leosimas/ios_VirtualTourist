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
        var components = URLComponents()
        components.scheme = Constants.Flickr.APIScheme
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components
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
        
        params[Constants.FlickrParameterKeys.Latitude] = String(coordinate.latitude)
        params[Constants.FlickrParameterKeys.Longitude] = String(coordinate.longitude)
        params[Constants.FlickrParameterKeys.Radius] = Constants.FlickrParameterValues.Radius
        params[Constants.FlickrParameterKeys.RadiusUnit] = Constants.FlickrParameterValues.UnitKM
        
        if page != nil {
            params[Constants.FlickrParameterKeys.Page] = String(page!)
        }
        
        let components = createBasicUrl(parameters: params as [String : AnyObject])
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
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
        
        task.resume()
    }
    
    func requestPagesInfo( coordinate : CLLocationCoordinate2D, completion : @escaping ((Int?, Int?, Int?, String?) -> Void)) {
        requestPhotos(coordinate: coordinate, page : nil) { (photosObj, errorMessage) in
            if errorMessage != nil {
                completion(nil, nil, nil, errorMessage)
                return
            }
            
            guard let totalPages = photosObj?[Constants.FlickrResponseKeys.Pages] as? Int,  let totalPhotosString = photosObj?[Constants.FlickrResponseKeys.Total] as? String, let perPage = photosObj?[Constants.FlickrResponseKeys.PerPage] as? Int else {
                completion(nil, nil, nil, Constants.ErrorMessages.ParseJson)
                return
            }
            
            
            completion(totalPages, Int(totalPhotosString), perPage, nil)
        }
    }
    
    func requestPhotosFor(coordinate : CLLocationCoordinate2D, completion : @escaping (([[String : AnyObject?]]?, String?) -> Void)) {
        
        requestPagesInfo(coordinate: coordinate) { (totalPages, totalPhotos, perPage, errorMessage) in
            if errorMessage != nil {
                completion(nil, errorMessage)
                return
            }
            
            let maxPhotos = min(Constants.Flickr.MaxPhotos, totalPhotos!)
            
            let selectedPage = Int(arc4random_uniform(UInt32( maxPhotos / perPage! )) + 1)
            
            self.requestPhotos(coordinate: coordinate, page: selectedPage) { (photosObj, errorMessage) in
                if errorMessage != nil {
                    completion(nil, errorMessage)
                    return
                }
                
                guard let photos = photosObj?[Constants.FlickrResponseKeys.Photo] as? [[String : AnyObject?]] else {
                    completion(nil, Constants.ErrorMessages.ParseJson)
                    return
                }
                
                completion(photos, nil)
            }
        }
    }
    
}
