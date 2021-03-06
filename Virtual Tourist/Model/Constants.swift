//
//  Constants.swift
//  Virtual Tourist
//
//  Created by SoSucesso on 07/09/17.
//  Copyright © 2017 Leonardo Simas. All rights reserved.
//

struct Constants {
    
    // MARK: Flickr
    struct Flickr {
        static let APIScheme = "https"
        static let APIHost = "api.flickr.com"
        static let APIPath = "/services/rest"
        static let MaxPhotos = 4000
    }
    
    // MARK: Flickr Parameter Keys
    struct FlickrParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let SafeSearch = "safe_search"
        static let Page = "page"
        static let PerPage = "per_page"
        static let Latitude = "lat"
        static let Longitude = "lon"
        static let Radius = "radius"
        static let RadiusUnit = "radius_unit"
    }
    
    // MARK: Flickr Parameter Values
    struct FlickrParameterValues {
        static let SearchMethod = "flickr.photos.search"
        static let APIKey = "998f07a4043dd4814f4796bca1392054"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1" /* 1 means "yes" */
        static let GalleryPhotosMethod = "flickr.galleries.getPhotos"
        static let MediumURL = "url_m"
        static let UseSafeSearch = "1"
        static let PerPage = "12"
        static let UnitKM = "km"
        static let Radius = "10"
    }
    
    // MARK: Flickr Response Keys
    struct FlickrResponseKeys {
        static let Status = "stat"
        static let Message = "message"
        
        static let Photos = "photos"
        static let Photo = "photo"
        static let Title = "title"
        static let MediumURL = "url_m"
        static let Pages = "pages"
        static let Total = "total"
        static let Id = "id"
        static let PerPage = "perpage"
    }
    
    // MARK: Flickr Response Values
    struct FlickrResponseValues {
        static let OKStatus = "ok"
    }
    
    struct ErrorMessages {
        static let ParseJson = "Failed to parse JSON response"
    }
    
    struct UserDefaults {
        static let MapCenterLatitude = "mapCenterLatitude"
        static let MapCenterLongitude = "mapCenterLongitude"
        static let MapCenterLatitudeDelta = "mapCenterLatitudeDelta"
        static let MapCenterLongitudeDelta = "mapCenterLongitudeDelta"
    }
    
}
