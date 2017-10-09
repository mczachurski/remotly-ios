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
        
        versionOutlet.text = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        if let selectedIndexPath = tableView.indexPathForSelectedRow
        {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
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
    
    fileprivate func gotoReviews()
    {
        let address = "itms-apps://itunes.apple.com/app/id1023395666"
        let url = URL(string: address)
        UIApplication.shared.openURL(url!)
    }
    
    fileprivate func gotoRemarks()
    {
        let systemVersion = UIDevice.current.systemVersion
        let model = UIDevice.current.model
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        
        let recipients = "mailto:mczachurski@icloud.com?subject=My remarks for Remotly app"
        let body = "&body=<br /><br />System: \(systemVersion)<br />Model: \(model)<br />Remotly: \(appVersion!)<br />"
        var email = "\(recipients)\(body)"
        email = email.addingPercentEscapes(using: String.Encoding.utf8)!
        
        let url = URL(string: email)
        UIApplication.shared.openURL(url!)
    }
    
    fileprivate func gotoGithub()
    {
        let address = "https://github.com/mczachurski/remotly-ios"
        let url = URL(string: address)
        UIApplication.shared.openURL(url!)
    }
}
