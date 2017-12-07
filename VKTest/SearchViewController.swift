//
//  SearchViewController.swift
//  VKTest
//
//  Created by ILYA Abramovich on 03.12.2017.
//  Copyright © 2017 ABR. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITextFieldDelegate {
    
    var userOrGroup = ""
    var id = "1"
    var idParam = "owner_id"
    var numberOfPosts = 50
    var posts = [Item]()
    var profiles = [Profiles]()
    var groups = [Groups]()
    var errorData: Data? { didSet { decodeError(errorData!) } }
    var errorCode: Int?
    var errorMsg: String?
    
    @IBOutlet weak var idTextField: UITextField!
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        idTextField.resignFirstResponder()
        return true
    }
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBAction func segmentControlChanged(_ sender: UISegmentedControl) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            userOrGroup = ""
        case 1:
            userOrGroup = "-"
        default:
            break
        }
    }
    
    
    @IBOutlet weak var countLabel: UILabel!
    
    @IBAction func countSliderChanged(_ sender: UISlider) {
        var s = "s"
        numberOfPosts = Int(sender.value)
        if numberOfPosts == 1 { s = "" }
        countLabel.text = "No more then \(Int(sender.value)) post\(s)"
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        downloadJSON {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.activityIndicator.stopAnimating()
            
            // Prepare to segue to the Wall Table View Controller
            guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WallTV") as? WallTableViewController else {
                print("Couldn't instantiate View Controller with identifier WallTVC")
                return
            }
            self.errorLabel.text = ""
            vc.posts = self.posts
            vc.profiles = self.profiles
            vc.groups = self.groups
            vc.title = "\(self.id)'s wall"
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func downloadJSON(completion: @escaping () -> ()) {
        
        // Check what is entered in the text field: id or domain
        if !idTextField.text!.isEmpty {
            if let intId = Int(idTextField.text!), String(intId) == idTextField.text! {
                id = idTextField.text!
                idParam = "owner_id"
            } else {
                id = idTextField.text!
                userOrGroup = ""
                idParam = "domain"
            }
        } else {
            id = "1"
            idParam = "owner_id"
        }
        
        // Set URL
        let jsonUrlString = "https://api.vk.com/method/wall.get?\(idParam)=\(userOrGroup)\(id)&access_token=19b67eef19b67eef19b67eef1d19e9d459119b619b67eef43a3e0a2f1ebb1ba42c6cd49&count=\(numberOfPosts)&extended=1&v=5.69"
        
        // Download and decode JSON
        guard let url = URL(string: jsonUrlString) else { return }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        activityIndicator.startAnimating()
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else { return }
            do {
                let resp = try JSONDecoder().decode(VKResponse.self, from: data)
                DispatchQueue.main.sync {
                    self.posts = resp.response.items
                    self.profiles = resp.response.profiles
                    self.groups = resp.response.groups
                    completion()
                }
            } catch {
                print("Error = JSONError: \n \(error) \n")
                self.errorData = data
            }
            }.resume()
    }
    
    // If the response is an error, "error data" is send to this method for decoding
    // and then the "error data" will be shown in the errorLabel under the search button
    func decodeError(_ error: Data) {
        do {
            let err = try JSONDecoder().decode(ErrorResponse.self, from: error)
            DispatchQueue.main.sync {
                errorCode = err.error.error_code
                errorMsg = err.error.error_msg
                errorLabel.text = "\(errorMsg!)\nError code: \(errorCode!)"
                errorLabel.isHidden = false
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.activityIndicator.stopAnimating()
            }
        } catch {
            errorLabel.text = "Unknow error\n\(error)"
            errorLabel.isHidden = false
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.activityIndicator.stopAnimating()
            print("DecodeError error: \n \(error) \n")
        }
    }
}

