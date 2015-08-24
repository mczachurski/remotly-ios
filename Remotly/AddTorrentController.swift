//
//  AddTorrentController.swift
//  
//
//  Created by Marcin Czachurski on 24.08.2015.
//
//

import UIKit

class AddTorrentController: UIViewController
{
    var fileUrl:NSURL?
    @IBOutlet weak var fileNameOutlet: UILabel!
    
    override func viewDidLoad()
    {
        fileNameOutlet.text = fileUrl?.lastPathComponent
    }
    
    @IBAction func cancelAction(sender: AnyObject)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func doneAction(sender: AnyObject)
    {
        var transmissionClient = TransmissionClient()
        transmissionClient.addTorrent(fileUrl!, isExternal:false, onCompletion: { (error) -> Void in
            if(error != nil)
            {
                // Print error.
            }
            else
            {
                AppDelegate.shouldRefreshList = true
            }

            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
}
