//
//  TorrentsCell.swift
//  
//
//  Created by Marcin Czachurski on 31.07.2015.
//
//

import UIKit

class TorrentsCell: UITableViewCell {
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var peerOutlet: UILabel!
    @IBOutlet weak var sizeOutlet: UILabel!
    @IBOutlet weak var downloadOutlet: UILabel!
    @IBOutlet weak var uploadOutlet: UILabel!
    @IBOutlet weak var progressOutlet: UIProgressView!
    
    func setTorrent(torrentInformation:TorrentInformation)
    {
        nameOutlet.text = torrentInformation.name
        sizeOutlet.text = torrentInformation.sizeInformationValue
        peerOutlet.text = torrentInformation.peersInformationValue
        downloadOutlet.text = torrentInformation.downloadInformationValue
        uploadOutlet.text = torrentInformation.uploadInformationValue
        progressOutlet.progress = Float(torrentInformation.downloadedPercentDone)
        
        if(torrentInformation.isDownloading)
        {
            nameOutlet.textColor = UIColor.blackColor()
        }
        else
        {
            nameOutlet.textColor = UIColor(red: 159.0/255.0, green: 158.0/255.0, blue: 168.0/255.0, alpha: 1.0)
        }
    }
    
}
