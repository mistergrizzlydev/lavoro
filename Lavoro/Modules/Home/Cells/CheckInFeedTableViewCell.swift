//
//  CheckInFeedTableViewCell.swift
//  Lavoro
//
//  Created by Manish on 01/05/20.
//  Copyright © 2020 Manish. All rights reserved.
//

import UIKit

class CheckInFeedTableViewCell: UITableViewCell {
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userImageButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var checkInImage: UIImageView!
    @IBOutlet weak var likesCount: UILabel!
    @IBOutlet weak var commentsCount: UILabel!
    @IBOutlet weak var locationNameBackgroundView: UIView!
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var postedComment: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var headerHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var moreButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        parentView.setLayer(cornerRadius: 8)
        userImage.setLayer(cornerRadius: 25)
        userImageButton.setLayer(cornerRadius: 25)
        checkInImage.setLayer(cornerRadius: 4)
        locationNameBackgroundView.setLayer(cornerRadius: 4)
        parentView.outerShadow(shadowOpacity: 0.1, shadowColor: .black)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(with object: Feed) {
        if let url = URL(string: object.user.avatar) {
            userImageButton.sd_setImage(with: url, for: .normal, completed: nil)
        } else {
            userImageButton.setImage(nil, for: .normal)
        }
        if let url = URL(string: object.location.image) {
            checkInImage.sd_setImage(with: url, completed: nil)
        } else {
            checkInImage.image = nil
        }
        username.text = object.user.username
        time.text = object.displayTime
        likesCount.text = object.likes
        commentsCount.text = object.comments
        locationName.text = object.location.name
        var userMessage = ""
        switch object.feedType {
        case .checkIn:
            userMessage = "Checked In\n"
            locationNameBackgroundView.backgroundColor = UIColor(hexString: "4CD964")
        case .checkOut:
            userMessage = "Checked Out\n"
            locationNameBackgroundView.backgroundColor = UIColor(hexString: "FF2D55")
        case .unknown:
            userMessage = "Handle the new type \n"
            locationNameBackgroundView.backgroundColor = UIColor(hexString: "FF2D55")
        }
        message.text = userMessage + object.location.name
        postedComment.text = object.postedComment
        if object.likeStatus == .loaded {
            likeButton.isHidden = false
            activityIndicator.stopAnimating()
        } else {
            likeButton.isHidden = true
            activityIndicator.startAnimating()
        }
        likeButton.isSelected = object.isLiked
        moreButton.isHidden = (object.user.id == AuthUser.getAuthUser()?.id)
    }
}
