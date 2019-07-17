//
//  NewsTableViewCell.swift
//  NewsReader
//
//  Created by Aleksei Artamonov on 7/8/19.
//  Copyright © 2019 test. All rights reserved.
//

import UIKit
import Kingfisher

class NewsTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var articleImageView: UIImageView!
    @IBOutlet weak var resourceLabel: UILabel!
    @IBOutlet weak var publishDateLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(with viewModel: NewsList.ShowNews.ViewModel.FeedViewModel) {
        titleLabel.text = viewModel.title
        if let image = resizeImage(image: viewModel.image, newWidth: articleImageView.frame.size.width) {
            articleImageView.image = image
        }
        resourceLabel.text = viewModel.resource
        publishDateLabel.text = viewModel.publishDate
        descriptionLabel.text = viewModel.description
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
