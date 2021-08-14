//
//  FeedViewController.swift
//  iSlide
//
//  Created by Luis Brito on 8/5/21.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    let myResfreshControl = UIRefreshControl()
    var numberOfPosts = Int()
    
    //To display a text view that appears above the keyboard
    var commentBar = MessageInputBar()
    var showCommentBar = false
    var selectedPost: PFObject!
    
    var posts = [PFObject]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadPosts()
        
        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self

        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .interactive
        
        myResfreshControl.addTarget(self, action: #selector(loadPosts), for: .valueChanged)
        tableView.refreshControl = myResfreshControl
        
        // Make keyboard dissmis from screen when it's not needed
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadMorePosts()
    }
    
    @objc func loadPosts() {
        numberOfPosts = 20
        let query = PFQuery(className: "Posts")
    
        // If you do not include the key then it'll just access the reference (the pointer without the object)
        query.includeKeys(["author", "comments", "comments.author"])
        query.limit = numberOfPosts
        query.findObjectsInBackground { (posts, error) in
            if posts != nil {
                self.posts.removeAll()
                self.posts = posts!
                self.tableView.reloadData()
                self.myResfreshControl.endRefreshing()
            } else {
                print("Error: \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    // Implement infinite scrolls
    func loadMorePosts(){
        let query = PFQuery(className: "Posts")
        numberOfPosts += 5
        
        query.includeKeys(["author", "comments", "comments.author"])
        query.limit = numberOfPosts
        
        query.findObjectsInBackground { (posts, error) in
            if posts != nil {
                self.posts.removeAll()
                self.posts = posts!
                self.tableView.reloadData()
                self.myResfreshControl.endRefreshing()
            } else {
                print("Error: \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // To trigger when approaching the end of the table view while scrolling
        if indexPath.row + 1 == posts.count {
            loadMorePosts()
        }
    }
    
    
    @objc func keyboardWillBeHidden(note: Notification) {
        // This will toggle the keyboard after dismmiss, and clear the text in the keyboard
        commentBar.inputTextView.text = nil
        showCommentBar = false
        becomeFirstResponder()

    }

    override var inputAccessoryView: UIView? {
        return commentBar
    }

    override var canBecomeFirstResponder: Bool {
        return showCommentBar
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        // Create the comment
        let comment = PFObject(className: "Comments")
        comment["text"] = text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()!

        selectedPost.add(comment, forKey: "comments")

        selectedPost.saveInBackground { (success, error) in
            if success {
                print("Comments saved.")
            } else {
                print("Error saving comments: \(String(describing: error?.localizedDescription))")
            }
        }
        
        tableView.reloadData()
        
        //Clear and dismiss the input bar
        commentBar.inputTextView.text = nil
        
        showCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Since there a many posts, we need access just one plus the comments of that one post. (this set up is similar to a 2D array)
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        return comments.count + 2
    }
    
    // to get however many posts there are in the database
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "postCell") as! PostCell
            
            let user = post["author"] as! PFUser
            cell.userNameLabel.text = user.username
            cell.captionLabel.text = post["caption"] as? String
            
            let imageFile = post["image"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)!
            
            cell.feedImageView.af.setImage(withURL: url)
            
            return cell
        } else if indexPath.row <= comments.count  {
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell") as! CommentCell
            let comment = comments[indexPath.row - 1]
            let user = comment["author"] as! PFUser
            
            cell.userNameLabel.text = user.username
            cell.commentLabel.text = comment["text"] as? String
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addCommentCell")!
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? [] //PFObject(className: "Comments")
        
        if indexPath.row == comments.count + 1 {
            showCommentBar = true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
            
            // Store post to be able to keep track of post when creating a comment
            selectedPost = post
        }
    }
    
    @IBAction func onLogOut(_ sender: Any) {
        PFUser.logOut()
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(identifier: "LoginViewController")
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let delegate = windowScene.delegate as? SceneDelegate else { return }
        delegate.window?.rootViewController = loginViewController
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
