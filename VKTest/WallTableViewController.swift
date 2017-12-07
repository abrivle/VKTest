//
//  WallTableViewController.swift
//  VKTest
//
//  Created by ILYA Abramovich on 03.12.2017.
//  Copyright © 2017 ABR. All rights reserved.
//

import UIKit

class WallTableViewController: UITableViewController {
    
    var posts = [Item]()
    var profiles = [Profiles]()
    var groups = [Groups]()
    var rowNumber = 0
    var errorCode: Int?
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        rowNumber = indexPath.row
        
        // Prepare to segue to the Detail Table View Controller
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailTV") as? DetailTableViewController else {
            print("Couldn't instantiate View Controller with identifier WallTVC")
            return
        }
        vc.rowNumber = rowNumber
        vc.post = posts[rowNumber]
        vc.profiles = profiles
        vc.groups = groups
        vc.title = "Post"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath)
        let post: Item = posts[indexPath.row]
        if let postCell = cell as? PostTableViewCell {
            
            // MARK: - Post
            // Define who create a post
            let fromId = post.fromId
            // If user create post. Set user Name and Photo
            if fromId > 0, let i = profiles.index(where: { $0.id == fromId }) {
                postCell.nameLabel.text = profiles[i].firstName! + " " + profiles[i].lastName!
                if profiles[i].online == 1 { postCell.nameLabel.text! += " (online)" }
                if let url = profiles[i].photo {
                    postCell.setPhotoImageView(url)
                }
                // If group create a post. Set group Name and Photo
            } else if fromId < 0, let i = groups.index(where: { $0.id == -fromId }) {
                postCell.nameLabel.text = groups[i].name!
                if let url = groups[i].photo {
                    postCell.setPhotoImageView(url)
                }
            }
            // Set the Date of creation a post
            postCell.dateLabel.text = "\(setDate(fromDouble: post.date))"
            // Set the Text of the post, Likes, Reposts, Comments, Views, Ads Marker
            postCell.postTextLabel.text = post.text
            postCell.likesLabel.text = "\(post.likes!.count)"
            postCell.repostsLabel.text = "\(post.reposts!.count)"
            postCell.commentsLabel.text = "\(post.comments!.count)"
            if post.markedAsAds == 1 {
                postCell.markedAsAds.text = "Рекламная запись"
                postCell.markedAsAds.isHidden = false
            } else { postCell.markedAsAds.isHidden = true }
            // VK show the Views of post only from the beginning of 2018, that's why we need in next if...
            if let views = post.views?.count {
                postCell.viewsLabel.text = "\(views)"
            } else { postCell.viewsLabel.text = "---" }
            
            // If post have some Attachments
            if let attachments = post.attachments {
                postCell.postImageDescription.isHidden = false
                postCell.postImageDescription.text = ""
                for attachment in attachments {
                    switch attachment.type {
                    case "photo":
                        postCell.postImageDescription.text! += "📷 "
                    case "video":
                        postCell.postImageDescription.text! += "🎥 "
                    case "doc":
                        postCell.postImageDescription.text! += "📄 "
                    case "link":
                        postCell.postImageDescription.text! += "📌 "
                    default:
                        break
                    }
                }
            } else { postCell.postImageDescription.isHidden = true }
            
            // MARK: - Repost
            if let repost = post.copyHistory?[0] {
                postCell.repostStack.isHidden = false
                postCell.repostPhotoIV.isHidden = false
                postCell.repostIcon.isHidden = false
                postCell.repostName.isHidden = false
                postCell.repostDate.isHidden = false
                
                // Define who create a repost
                let fromId = repost.fromId
                // If user create repost. Set user Name and Photo
                if fromId > 0, let i = profiles.index(where: { $0.id == fromId }) {
                    postCell.repostName.text = profiles[i].firstName! + " " + profiles[i].lastName!
                    if profiles[i].online == 1 { postCell.repostName.text! += " (online)" }
                    if let url = profiles[i].photo {
                        postCell.setRepostPhotoIV(url)
                    }
                    // If group create a repost. Set group Name and Photo
                } else if fromId < 0, let i = groups.index(where: { $0.id == -fromId }) {
                    postCell.repostName.text = groups[i].name!
                    if let url = groups[i].photo {
                        postCell.setRepostPhotoIV(url)
                    }
                }
                
                // Set the Date of creation a repost
                postCell.repostDate.text = "\(setDate(fromDouble: repost.date))"
                // Set the Text of the repost
                postCell.repostText.text = repost.text
                postCell.repostText.isHidden = false
                
                // If repost have some Attachments
                if let attachments = repost.attachments {
                    postCell.repostImageDescription.isHidden = false
                    postCell.repostImageDescription.text = ""
                    for attachment in attachments {
                        switch attachment.type {
                        case "photo":
                            postCell.repostImageDescription.text! += "📷 "
                        case "video":
                            postCell.repostImageDescription.text! += "🎥 "
                        case "doc":
                            postCell.repostImageDescription.text! += "📄 "
                        case "link":
                            postCell.repostImageDescription.text! += "📌 "
                        default:
                            break
                        }
                    }
                } else { postCell.repostImageDescription.isHidden = true }
            } else { postCell.repostStack.isHidden = true }
        }
        return cell
    }
    
    func setDate(fromDouble: Double) -> String {
        let date = Date(timeIntervalSince1970: fromDouble)
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "dd MMMM yy в HH:mm"
        return formatter.string(from: date)
    }
}

