//
//  PostTableViewCell.swift
//  VKTest
//
//  Created by ILYA Abramovich on 03.12.2017.
//  Copyright © 2017 ABR. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var postTextLabel: UILabel!
    @IBOutlet weak var postImageDescription: UILabel!
    
    @IBOutlet weak var repostStack: UIStackView!
    @IBOutlet weak var repostPhotoIV: UIImageView!
    @IBOutlet weak var repostIcon: UIImageView!
    @IBOutlet weak var repostName: UILabel!
    @IBOutlet weak var repostDate: UILabel!
    @IBOutlet weak var repostText: UILabel!
    @IBOutlet weak var repostImageDescription: UILabel!
    
    @IBOutlet weak var markedAsAds: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var repostsLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    
    var uploadedImage: UIImage?
    let imageCache = NSCache<NSString, UIImage>()
    
    func setPhotoImageView(_ url: URL) {
        downloadImage(url) { [weak self] in
            self?.photoImageView.layer.cornerRadius = CGFloat(25)
            self?.photoImageView.clipsToBounds = true
            self?.photoImageView.image = self?.uploadedImage
        }
    }
    
    func setRepostPhotoIV(_ url: URL) {
        downloadImage(url) { [weak self] in
            self?.repostPhotoIV.layer.cornerRadius = CGFloat(20)
            self?.repostPhotoIV.clipsToBounds = true
            self?.repostPhotoIV.image = self?.uploadedImage
        }
    }
    
    func downloadImage(_ url: URL, comleted: @escaping () -> ()) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let checkURL = url
        uploadedImage = nil
        
        // Cheking the image in the cache at the URL
        if let imageFromCache = imageCache.object(forKey: url.absoluteString as NSString) {
            uploadedImage = imageFromCache
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return print("Download error") }
            DispatchQueue.main.sync { [weak self] in
                let imageToCache = UIImage(data: data)
                if checkURL == url {
                    self?.uploadedImage = imageToCache!
                } else {
                    self?.uploadedImage = #imageLiteral(resourceName: "placeholder_banned_128")
                }
                self?.imageCache.setObject(imageToCache!, forKey: url.absoluteString as NSString)
                comleted()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            }.resume()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

