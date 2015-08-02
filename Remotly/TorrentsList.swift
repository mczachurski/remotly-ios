//
//  TorrentsList.swift
//  
//
//  Created by Marcin Czachurski on 30.07.2015.
//
//

import UIKit

class TorrentsList: UITableViewController {

    var transmissionClient = TransmissionClient()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = false
        
        transmissionClient.loadTorrents(torrentsLoadedCallback)
    }

    func torrentsLoadedCallback(error:NSError?)
    {
        if(error == nil)
        {
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return transmissionClient.torrentsInformation.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("TorrentCell", forIndexPath: indexPath) as! TorrentsCell

        let torrentInformation = transmissionClient.torrentsInformation[indexPath.row]
        cell.setTorrent(torrentInformation)

        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
}
