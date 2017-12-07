//
//  PostTableViewController.swift
//  VKTest
//
//  Created by ILYA Abramovich on 03.12.2017.
//  Copyright © 2017 ABR. All rights reserved.
//

import UIKit

class DetailTableViewController: UITableViewController {
    
    var rowNumber = 0
    var post: Item?
    var profiles = [Profiles]()
    var groups = [Groups]()
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
        guard let post = post else { return cell }
        if let postCell = cell as? DetailTableViewCell {
            
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
            postCell.dateLabel.text = "\(setDate(post.date))"
            // Set the Text of the post, Likes, Reposts, Comments, Views, Ads Marker
            if post.text != "" { postCell.postTextView.text = post.text
            } else { postCell.postTextView.isHidden = true }
            postCell.likesLabel.text = "\(post.likes!.count)"
            postCell.repostsLabel.text = "\(post.reposts!.count)"
            postCell.commentsLabel.text = "\(post.comments!.count)"
            if post.markedAsAds == 1 {
                postCell.markedAsAds.text = "Рекламная запись"
                postCell.markedAsAds.isHidden = false
            }
            // VK show the Views of post only from the beginning of 2018, that's why we need in next if...
            if let views = post.views?.count {
                postCell.viewsLabel.text = "\(views)"
            } else { postCell.viewsLabel.text = "---" }
            
            // If post have some Attachments
            if let attachments = post.attachments {
                
                // "Unhide" the required number of imageViews and the text field under imageViews
                var i = 0
                postCell.imagesStack.isHidden = false
                let attachCount = attachments.count
                if attachCount > 2 { postCell.imagesStack2.isHidden = false }
                if attachCount > 4 { postCell.imagesStack3.isHidden = false }
                if attachCount > 6 { postCell.imagesStack4.isHidden = false }
                if attachCount > 8 { postCell.imagesStack5.isHidden = false }
                for image in postCell.postImages {
                    i += 1
                    if i <= attachCount { image.isHidden = false }
                }
                postCell.postImageDescription.text = ""
                postCell.postImageDescription.isHidden = false
                
                
                // Download Attacments
                for attachment in attachments {
                    switch attachment.type {
                    case "photo":
                        postCell.postImageDescription.text! += "Photo: (\(attachment.photo?.width ?? 0)x\(attachment.photo?.height ?? 0)) "
                        guard let url = chooseSize(photoStruct: attachment.photo) else {
                            postCell.setDefaultImage(postCell.postImages, img: #imageLiteral(resourceName: "ic_profile_photos_placeholder"))
                            break
                        }
                        postCell.setPostImage(url)
                    case "video":
                        postCell.postImageDescription.text! += "\(attachment.video?.title ?? "Video") (\(attachment.video?.duration ?? 1)sec ・\(attachment.video?.views ?? 0)views) "
                        guard let url = chooseSize(videoStruct: attachment.video) else {
                            postCell.setDefaultImage(postCell.postImages, img: #imageLiteral(resourceName: "ic_profile_videos_placeholder"))
                            break
                        }
                        postCell.setPostImage(url)
                    case "doc":
                        postCell.postImageDescription.text! += "\(attachment.doc?.title ?? "Doc"): \((attachment.doc?.url)!) "
                        guard let url = chooseSize(doc: attachment.doc?.preview?.photo?.sizes) else {
                            postCell.setDefaultImage(postCell.postImages, img: #imageLiteral(resourceName: "ic_profile_docs_placeholder"))
                            break
                        }
                        postCell.setPostImage(url)
                    case "link":
                        postCell.postImageDescription.text! += "\(attachment.link?.title ?? "Link"): \((attachment.link?.url)!) "
                        guard let url = chooseSize(photoStruct: attachment.link?.photo) else {
                            postCell.setDefaultImage(postCell.postImages, img: #imageLiteral(resourceName: "ic_profile_link"))
                            break
                        }
                        postCell.setPostImage(url)
                    default:
                        break
                    }
                }
            }
            
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
                postCell.repostDate.text = "\(setDate(repost.date))"
                // Set the Text of the repost
                if repost.text != "" {
                    postCell.repostText.text = repost.text
                    postCell.repostText.isHidden = false
                } else { postCell.repostText.isHidden = true }
                
                // If repost have some Attachments
                if let attachments = repost.attachments {
                    
                    // "Unhide" the required number of imageViews and the text field under imageViews
                    var i = 0
                    postCell.repostImagesStack.isHidden = false
                    let attachCount = attachments.count
                    if attachCount > 2 { postCell.repostImagesStack2.isHidden = false }
                    if attachCount > 4 { postCell.repostImagesStack3.isHidden = false }
                    if attachCount > 6 { postCell.repostImagesStack4.isHidden = false }
                    if attachCount > 8 { postCell.repostImagesStack5.isHidden = false }
                    for image in postCell.repostImages {
                        i += 1
                        if i <= attachCount { image.isHidden = false }
                    }
                    postCell.repostImageDescription.text = ""
                    postCell.repostImageDescription.isHidden = false
                    
                    // Download Attacments
                    for attachment in attachments {
                        switch attachment.type {
                        case "photo":
                            postCell.repostImageDescription.text! += "Photo: \(attachment.photo?.width ?? 0)x\(attachment.photo?.height ?? 0) "
                            guard let url = chooseSize(photoStruct: attachment.photo) else {
                                postCell.setDefaultImage(postCell.repostImages, img: #imageLiteral(resourceName: "ic_profile_photos_placeholder"))
                                break
                            }
                            postCell.setRepostImage(url)
                        case "video":
                            postCell.repostImageDescription.text! += "\(attachment.video?.title ?? "Video") (\(attachment.video?.duration ?? 1)sec ・\(attachment.video?.views ?? 0)views) "
                            guard let url = chooseSize(videoStruct: attachment.video) else {
                                postCell.setDefaultImage(postCell.repostImages, img: #imageLiteral(resourceName: "ic_profile_videos_placeholder"))
                                break
                            }
                            postCell.setRepostImage(url)
                        case "doc":
                            postCell.repostImageDescription.text! += "\(attachment.doc?.title ?? "Doc"): \((attachment.doc?.url)!) "
                            guard let url = chooseSize(doc: attachment.doc?.preview?.photo?.sizes) else {
                                postCell.setDefaultImage(postCell.repostImages, img: #imageLiteral(resourceName: "ic_profile_docs_placeholder"))
                                break
                            }
                            postCell.setRepostImage(url)
                        case "link":
                            postCell.repostImageDescription.text! += "\(attachment.link?.title ?? "Link"): \((attachment.link?.url)!) "
                            guard let url = chooseSize(photoStruct: attachment.link?.photo) else {
                                postCell.setDefaultImage(postCell.repostImages, img: #imageLiteral(resourceName: "ic_profile_link"))
                                break
                            }
                            postCell.setRepostImage(url)
                        default:
                            break
                        }
                    }
                } else {
                    postCell.repostImagesStack.isHidden = true
                    postCell.repostImageDescription.isHidden = true
                }
            } else { postCell.repostStack.isHidden = true }
        }
        return cell
    }
    
    func setDate(_ fromDouble: Double) -> String {
        let date = Date(timeIntervalSince1970: fromDouble)
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "dd MMMM yy в HH:mm"
        return formatter.string(from: date)
    }
    
    // Methods for selecting the largest possible image size
    func chooseSize(photoStruct: Photo?) -> URL? {
        guard let photo75 = photoStruct?.photo_75 else { return nil }
        guard let photo130 = photoStruct?.photo_130 else { return photo75 }
        guard let photo604 = photoStruct?.photo_604 else { return photo130 }
        guard let photo807 = photoStruct?.photo_807 else { return photo604 }
        guard let photo1280 = photoStruct?.photo_1280 else { return photo807 }
        guard let photo2560 = photoStruct?.photo_2560 else { return photo1280 }
        return photo2560
    }
    
    func chooseSize(videoStruct: Video?) -> URL? {
        guard let video130 = videoStruct?.photo_130 else { return nil}
        guard let video320 = videoStruct?.photo_320 else { return video130 }
        guard let video640 = videoStruct?.photo_640 else { return video320 }
        guard let video800 = videoStruct?.photo_800 else { return video640 }
        return video800
    }
    
    func chooseSize(doc: [Sizes]?) -> URL? {
        if let i = doc?.index(where: { $0.type == "y" }) { return doc![i].src
        } else if let i = doc?.index(where: { $0.type == "x" }) { return doc![i].src
        } else if let i = doc?.index(where: { $0.type == "o" }) { return doc![i].src
        } else if let i = doc?.index(where: { $0.type == "m" }) { return doc![i].src
        } else if let i = doc?.index(where: { $0.type == "s" }) { return doc![i].src
        } else { return nil }
    }
}
