//
//  ServersCell.swift
//  
//
//  Created by Marcin Czachurski on 25.08.2015.
//
//

import UIKit

class ServersCell: UITableViewCell
{
    @IBOutlet weak var serverNameOutlet: UILabel!
    @IBOutlet weak var addressOutlet: UILabel!
    @IBOutlet weak var isDefaultOutlet: UIImageView!
    
    func setServer(server:Server, isDefault:Bool)
    {
        serverNameOutlet.text = server.name
        addressOutlet.text = server.address
        isDefaultOutlet.hidden = !isDefault
    }
}
