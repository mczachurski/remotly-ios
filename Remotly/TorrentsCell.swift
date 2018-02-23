//
//  TorrentsCell.swift
//  Remotly
//
//  Created by Marcin Czachurski on 30.07.2015.
//  Copyright (c) 2015 SunLine Technologies. All rights reserved.
//

import UIKit

class TorrentsCell: UITableViewCell
{
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var peerOutlet: UILabel!
    @IBOutlet weak var sizeOutlet: UILabel!
    @IBOutlet weak var downloadOutlet: UILabel!
    @IBOutlet weak var uploadOutlet: UILabel!
    @IBOutlet weak var progressOutlet: UIProgressView!
    @IBOutlet weak var imageStatusOutlet: UIImageView!
    
    func setTorrent(_ torrent:Torrent)
    {
        nameOutlet.text = torrent.name
        sizeOutlet.text = torrent.sizeInformationValue
        peerOutlet.text = torrent.peersInformationValue
        downloadOutlet.text = torrent.downloadInformationValue
        uploadOutlet.text = torrent.uploadInformationValue
        progressOutlet.progress = Float(torrent.downloadedPercentDone)
        
        if(torrent.isDownloading)
        {
            nameOutlet.textColor = UIColor.black
            imageStatusOutlet.image = UIImage(named: "play1")
        }
        else if (torrent.isPaused)
        {
            imageStatusOutlet.image = UIImage(named: "pause")
            nameOutlet.textColor = ColorsHandler.getGrayColor()
        }
        else
        {
            imageStatusOutlet.image = UIImage(named: "play2")
            nameOutlet.textColor = ColorsHandler.getGrayColor()
        }
    }
    
}
