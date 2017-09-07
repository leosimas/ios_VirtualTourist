//
//  Dialogs.swift
//  On The Map
//
//  Created by SoSucesso on 27/08/17.
//  Copyright © 2017 Leonardo Simas. All rights reserved.
//

import UIKit

class Dialogs {
    
    static func alert(controller : UIViewController, title : String, message : String, completion : ((UIAlertAction) -> Void )? = nil) {
        DispatchQueue.main.async {
            let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: completion))
            controller.present(alertVC, animated: true, completion: nil)
        }
    }
    
    static func confirm(controller : UIViewController, title : String, message : String, completion : @escaping ((Bool)-> Void)) {
        DispatchQueue.main.async {
            let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                completion(true)
            }))
            alertVC.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action) in
                completion(false)
            }))
            controller.present(alertVC, animated: true, completion: nil)
        }
    }
    
}
