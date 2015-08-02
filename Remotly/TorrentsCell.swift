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
    @IBOutlet weak var sizeOutlet: UILabel!
    
    func setTorrent(torrentInformation:TorrentInformation)
    {
        nameOutlet.text = torrentInformation.name
        //sizeOutlet.text = torrentInformation.size
    }
    
}
