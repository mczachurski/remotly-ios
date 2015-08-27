//
//  AboutController.swift
//  
//
//  Created by Marcin Czachurski on 27.08.2015.
//
//

import UIKit

class AboutController: UITableViewController
{
    @IBOutlet weak var versionOutlet: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = true;
        
        versionOutlet.text = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        if let selectedIndexPath = tableView.indexPathForSelectedRow()
        {
            tableView.deselectRowAtIndexPath(selectedIndexPath, animated: true)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        switch(indexPath.row)
        {
            case 0:
                gotoReviews()
            case 1:
                gotoGithub()
            case 2:
                gotoRemarks()
            default:
                break;
        }
    }
    
    private func gotoReviews()
    {
        let address = "itms-apps://itunes.apple.com/app/id1023395666"
        let url = NSURL(string: address)
        UIApplication.sharedApplication().openURL(url!)
    }
    
    private func gotoRemarks()
    {
        let systemVersion = UIDevice.currentDevice().systemVersion
        let model = UIDevice.currentDevice().model
        let appVersion = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String
        
        let recipients = "mailto:mczachurski@icloud.com?subject=My remarks for Remotly app"
        let body = "&body=<br /><br />System: \(systemVersion)<br />Model: \(model)<br />Remotly: \(appVersion!)<br />"
        var email = "\(recipients)\(body)"
        email = email.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        let url = NSURL(string: email)
        UIApplication.sharedApplication().openURL(url!)
    }
    
    private func gotoGithub()
    {
        let address = "https://github.com/mczachurski/remotly-ios"
        let url = NSURL(string: address)
        UIApplication.sharedApplication().openURL(url!)
    }
}
