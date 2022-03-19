//
//  ProfileViewController.swift
//  Twitter
//
//  Created by LYON on 3/17/22.
//  Copyright © 2022 Dan. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var tweetsLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var tweetArray = [NSDictionary]()
    var numberOfTweet: Int!
    
    let myRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadUserInfo()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // Refresh tweets
        myRefreshControl.addTarget(self, action:#selector(loadTweet), for: .valueChanged)
        self.tableView.refreshControl = myRefreshControl
        
        // Set the row height
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Load tweets
        self.loadTweet()
    }
    
    // Load User info
    func loadUserInfo() {
        TwitterAPICaller.client?.userInfo(
            success: { data in
                let imageUrl = URL(string: data["profile_image_url_https"] as! String)
                let pic = try? Data(contentsOf: imageUrl!)
                if let profilePic = pic {
                    self.profileImage.image = UIImage(data: profilePic)
                }

                self.nameLabel.text = data["name"] as? String
                self.screenNameLabel.text = "@" + (data["screen_name"] as! String)
                self.descriptionLabel.text = data["description"] as? String
                self.followingLabel.text = String(data["friends_count"] as! Int) + " Following"
                self.followersLabel.text = String(data["followers_count"] as! Int) + " Followers"
                self.tweetsLabel.text = String(data["statuses_count"] as! Int) + " Tweets"
                
            }, failure: { error in
                print(error)
            }
        )
    }
    
    // Load tweets
    @objc func loadTweet() {
        
        numberOfTweet = 20
        let myUrl = "https://api.twitter.com/1.1/statuses/user_timeline.json"
        let myParams = ["count": numberOfTweet]
        
        TwitterAPICaller.client?.getDictionariesRequest(url: myUrl, parameters: myParams as [String : Any], success: { (tweets: [NSDictionary]) in
            
            self.tweetArray.removeAll()
            for tweet in tweets {
                self.tweetArray.append(tweet)
            }
            
            self.tableView.reloadData()
            self.myRefreshControl.endRefreshing()
            
        }, failure: { Error in
            print("Could not retreive tweets!")
            print(Error.localizedDescription)
        })
    }
    
    // Infinite getting tweets
    func loadMoreTweet() {
        
        numberOfTweet = numberOfTweet + 20
        let myUrl = "https://api.twitter.com/1.1/statuses/user_timeline.json"
        let myParams = ["count": numberOfTweet]
        
        TwitterAPICaller.client?.getDictionariesRequest(url: myUrl, parameters: myParams as [String : Any], success: { (tweets: [NSDictionary]) in
            
            self.tweetArray.removeAll()
            for tweet in tweets {
                self.tweetArray.append(tweet)
            }
            
            self.tableView.reloadData()
            
        }, failure: { Error in
            print("Could not retreive tweets! \(Error)")
            print(Error.localizedDescription)
        })
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == tweetArray.count {
            loadMoreTweet()
        }
    }
    
    // Log out action
    @IBAction func logoutButton(_ sender: Any) {
        TwitterAPICaller.client?.logout()
        self.dismiss(animated: true, completion: nil)
        UserDefaults.standard.set(false, forKey: "userLoggedIn")
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell", for: indexPath) as! TweetCell
        
        // Get user name
        let user = tweetArray[indexPath.row]["user"] as! NSDictionary
        cell.userNameLabel.text = user["name"] as? String
        
        // Get tweet content
        cell.tweetContentLabel.text = tweetArray[indexPath.row]["text"] as? String
        
        // Get tweet info (screen name + post time)
        let screenName = "@" + (user["screen_name"] as! String)
        let postTime = tweetArray[indexPath.row]["created_at"] as! String
        let dateArray = postTime.split(separator: " ")
        let postDate = dateArray[1] + " " + dateArray[2]
        
        cell.timeLabel.text = String(screenName +  " · " + postDate)
        
        // Get user image
        let imageUrl = URL(string: (user["profile_image_url_https"] as? String)!)
        let data = try? Data(contentsOf: imageUrl!)

        if let imageData = data {
            cell.profileImage.image = UIImage(data: imageData)
            
            // Get media image
            let entities = tweetArray[indexPath.row]["entities"] as! NSDictionary
            if let media = entities["media"] as? [NSDictionary] {
                let mediaUrl = URL(string: (media[0]["media_url_https"] as? String)!)
                let mediaData = try? Data(contentsOf: mediaUrl!)

                if let mediaImageData = mediaData {
                    cell.mediaImage.image = UIImage(data: mediaImageData)
                } else {
                    cell.mediaImage.image = nil
                }
            } else {
                cell.mediaImage.image = nil
            }
        }
        
        // Set favortite tweet
        cell.setFavorite(tweetArray[indexPath.row]["favorited"] as! Bool)
        cell.tweetId = tweetArray[indexPath.row]["id"] as! Int
        
        // Set retweet
        cell.setRetweeted(tweetArray[indexPath.row]["retweeted"] as! Bool)
        
        return cell
    }
    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tweetArray.count
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
