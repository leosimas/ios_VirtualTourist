//
//  PhotoViewCell.swift
//  Virtual Tourist
//
//  Created by SoSucesso on 09/09/17.
//  Copyright © 2017 Leonardo Simas. All rights reserved.
//

import UIKit

class PhotoViewCell : UICollectionViewCell {
    
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    func setupCellWith(_ photo : Photo) {
        if photo.image == nil {
            showImage(false)
        } else {
            imageView.image = UIImage(data: photo.image! as Data)
            showImage(true)
        }
    }
    
    private func showImage(_ show : Bool) {
        imageView.isHidden = !show
        loadingView.isHidden = show
    }
    
}
