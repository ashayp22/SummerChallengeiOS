//
//  MentorModalController.swift
//  SummerChallengeiOS
//
//  Created by Ashay Parikh on 7/26/21.
//

import UIKit

class MentorModalController: UIViewController{
    
    var mentorImageURL = ""
    var mentorBio = ""
    var mentorName = ""
    
    
    @IBOutlet var mentorImage: UIImageView!
    @IBOutlet var mentorNameLabel: UILabel!
    @IBOutlet var mentorBioLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //Displays information about mentor, which we got from the table view cell in ViewController.swift
        
        self.mentorNameLabel.text = mentorName
        self.mentorBioLabel.text = mentorBio


        //Set alignment of the bio label to the center if the description is sort
        if(mentorBio.count <= 50) {
            self.mentorBioLabel.textAlignment = .center
        }
        
        self.mentorBioLabel.numberOfLines = 0

        
        let url = URL(string: mentorImageURL)!
        
       self.mentorImage.load(url: url)
    
        //Gives profile image circular shape
        self.mentorImage.layer.cornerRadius = self.mentorImage.frame.size.width / 2
        
        //Maintains aspect ratio while have the image fill the Image View
        self.mentorImage.contentMode = .scaleAspectFill
    }
    

    
}

