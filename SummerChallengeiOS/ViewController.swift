//
//  ViewController.swift
//  SummerChallengeiOS
//
//  Created by Ashay Parikh on 7/24/21.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var myTableView: UITableView!
    
    //Contains firstName, lastName, description, and profile (url)
    var mentorArray: [[String: Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        myTableView.dataSource = self;
        myTableView.delegate = self;
        
        
        /* GET mentor data from HackIllinois API using URLSession
         Source: https://www.appsdeveloperblog.com/http-get-request-example-in-swift/
         */

        let url = URL(string: "https://api.hackillinois.org/upload/blobstore/mentors/")
        guard let requestUrl = url else { fatalError() }

        // Create URL Request
        var request = URLRequest(url: requestUrl)

        // Specify HTTP Method to use
        request.httpMethod = "GET"

        //The dispatch group is used to notify the main thread that we have recieved the mentor data. Afterwards,
        //we reload the table view, which can be only done in the main thread.
        //Source: https://developer.apple.com/documentation/dispatch/dispatch_group
        
        let myGroup = DispatchGroup()

        myGroup.enter()

        // Send HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in

            guard let data = data, error == nil else { return }

            // Convert HTTP Response Data to dictionary

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any] ?? [:]

                let mentorData = json["data"] as? [[String: Any]] ?? []

                self.mentorArray = mentorData

                myGroup.leave()

            } catch {
                print(error)
                return
            }



        }
        task.resume()

        myGroup.notify(queue: .main) {
            self.myTableView.reloadData()
        }
    }
    
    //Specifies sections in the table view
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //Set the height of the table view -> this is dependent on the mentor description length
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let bio = mentorArray[indexPath.row]["description"] as? String ?? "No description"
        let bioLength = bio.count
        
        //I used regression to approximate a height value that doesn't leave any extra space
        //at the end of each table view cell.
        let rowHeight = round(325 * pow(1.0012, Double(bioLength)))

        return CGFloat(rowHeight)
    }
    
    //Number of cells
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mentorArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        //Load a custom cell that I created
        //Source: old project + https://www.youtube.com/watch?v=A7J0AmtVABg
        let cell = Bundle.main.loadNibNamed("MentorTableViewCell", owner: self, options: nil)?.first as! MentorTableViewCell
        
        //Get mentor data
        let fullName = (mentorArray[indexPath.row]["firstName"] as? String ?? "") + " " + (mentorArray[indexPath.row]["lastName"] as? String ?? "")
        let profile = mentorArray[indexPath.row]["profile"] as? String ?? ""
        let bio = mentorArray[indexPath.row]["description"] as? String ?? "No description"
        
        //Update text
        cell.nameLabel.text = fullName
        cell.bioLabel.text = bio

        //Set alignment of the bio label to the center if the description is sort
        if(bio.count <= 50) {
            cell.bioLabel.textAlignment = .center
        }
        
        let url = URL(string: profile)!
        
        cell.profileImage.load(url: url)
    
        //Gives profile image circular shape
        cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.width / 2
        
        //Maintains aspect ratio while have the image fill the Image View
        cell.profileImage.contentMode = .scaleAspectFill
        
        return cell
        
    }


}

