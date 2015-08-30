//
//  ThirdPartyController.swift
//  
//
//  Created by Marcin Czachurski on 27.08.2015.
//
//

import UIKit

class ThirdPartyController: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = true;
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
                gotoWebsite("https://icons8.com")
            case 1:
                gotoWebsite("https://github.com/SwiftyJSON/SwiftyJSON")
            case 2:
                gotoWebsite("https://github.com/bryx-inc/BRYXBanner")
            case 3:
                gotoWebsite("https://github.com/leoru/SwiftLoader")
            default:
                break;
        }
    }
    
    private func gotoWebsite(address:String)
    {
        let url = NSURL(string: address)
        UIApplication.sharedApplication().openURL(url!)
    }
}
