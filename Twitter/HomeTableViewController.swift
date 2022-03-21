//
//  HomeTableViewController.swift
//  Twitter
//
//  Created by LYON on 3/8/22.
//  Copyright © 2022 Dan. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController {
    
    var tweetArray = [NSDictionary]()
    var numberOfTweet: Int!
    
    let myRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

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

    // Load tweets
    @objc func loadTweet() {
        
        numberOfTweet = 20
        let myUrl = "https://api.twitter.com/1.1/statuses/home_timeline.json"
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
        let myUrl = "https://api.twitter.com/1.1/statuses/home_timeline.json"
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
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tweetArray.count
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
