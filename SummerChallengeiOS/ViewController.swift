//
//  ViewController.swift
//  SummerChallengeiOS
//
//  Created by Ashay Parikh on 7/24/21.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var myTableView: UITableView!
    @IBOutlet var backToTopButton: UIButton!
    
    //Contains firstName, lastName, description, and profile (url)
    var mentorArray: [[String: Any]] = []
    
    //The index of the mentor selected by the user
    var selectedMentorIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        myTableView.dataSource = self;
        myTableView.delegate = self;
        
        //Orange rgb
        let red = CGFloat(241 / 255)
        let green = CGFloat(143 / 255)
        let blue = CGFloat(0 / 255)
        let alpha = CGFloat(100 / 100)
        
        backToTopButton.layer.cornerRadius = 10
        backToTopButton.layer.borderWidth = 1
        backToTopButton.layer.borderColor = CGColor.init(red: red, green: green, blue: blue, alpha: alpha)
        
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
                
                /*This next piece organizes the mentors such that those with the default image are at the end.
                 */
                
                let defaultURL = "https://hackillinois-upload.s3.amazonaws.com/photos/mentors/default.png" //hard-coded value
                
                var end = self.mentorArray.count
                var i = 0
                
                while (i < end) {
                    let profile = self.mentorArray[i]["profile"] as? String ?? ""
                    
                    if(profile == defaultURL) {
                        self.mentorArray.append(self.mentorArray.remove(at: i))
                        i -= 1
                        end -= 1
                    }
                
                    i += 1
                }

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
    
    //Set the height of the table view cel
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 275
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
        
                
        //Update text
        cell.nameLabel.text = fullName

        let url = URL(string: profile)!
        
        cell.profileImage.load(url: url)
    
        //Gives profile image circular shape
        cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.width / 2
        
        //Maintains aspect ratio while have the image fill the Image View
        cell.profileImage.contentMode = .scaleAspectFill
        
        //Selected cell color
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.init(red: 48/255, green: 52/255, blue: 128/255, alpha: 0.15)
        cell.selectedBackgroundView = bgColorView
        
        return cell
        
    }

    @IBAction func scrollToTop(_ sender: Any) {
        //Source: https://programmingwithswift.com/swift-scroll-to-top-of-uitableview/
        //Scrolls to top of Table View
        
        let topRow = IndexPath(row: 0,
                                       section: 0)
        
        self.myTableView.scrollToRow(at: topRow,
                                   at: .top,
                                   animated: true)
    }
    
    //When a table view cell is selected
    func tableView(_ tableView: UITableView,
                       didSelectRowAt indexPath: IndexPath) {
        //record the cell that is selected
        self.selectedMentorIndex = indexPath.row
        
        //show the mentor modal
        self.performSegue(withIdentifier: "ShowMentor", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

           if segue.identifier == "ShowMentor"{
                let destinationVC = segue.destination as? MentorModalController
            
            if(self.selectedMentorIndex != -1) {
                
                //Getting the selected mentor infor
                let fullName = (mentorArray[self.selectedMentorIndex]["firstName"] as? String ?? "") + " " + (mentorArray[selectedMentorIndex]["lastName"] as? String ?? "")
                let profile = mentorArray[self.selectedMentorIndex]["profile"] as? String ?? ""
                let bio = mentorArray[self.selectedMentorIndex]["description"] as? String ?? "No description"
            
                //Sending over to modal
                destinationVC?.mentorImageURL = profile
                destinationVC?.mentorBio = bio
                destinationVC?.mentorName = fullName
            }

                
           }

        }
           
    
}

