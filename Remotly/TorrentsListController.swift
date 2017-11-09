//
//  TorrentsListController.swift
//  Remotly
//
//  Created by Marcin Czachurski on 30.07.2015.
//  Copyright (c) 2015 SunLine Technologies. All rights reserved.
//

import UIKit
import CoreData

class TorrentsListController: UITableViewController, UIAlertViewDelegate, UIActionSheetDelegate, NSFetchedResultsControllerDelegate
{
    var server:Server!
    fileprivate var transmissionClient:TransmissionClient!
    fileprivate var context: NSManagedObjectContext!
    fileprivate var reloadTimer:Timer?
    fileprivate var rateDownload:Int64 = 0
    fileprivate var rateUpload:Int64 = 0
    fileprivate let deleteTorrentButtonIndex = 1
    fileprivate let deleteTorrentWitDataButtonIndex = 2
    fileprivate var torrentToDelete:Torrent? = nil
    fileprivate var isAlternativeSpeedModeEnabled = false
    fileprivate var isDuringRequest = false
    
    @IBOutlet weak var downloadToolbarOutlet: UIBarButtonItem!
    @IBOutlet weak var uploadToolbarOutlet: UIBarButtonItem!
    @IBOutlet weak var speedModeOutlet: UIBarButtonItem!
    @IBOutlet weak var downloadImageOutlet: UIBarButtonItem!
    @IBOutlet weak var uploadImageOutlet: UIBarButtonItem!
    
  lazy var fetchedResultsController: NSFetchedResultsController = { () -> NSFetchedResultsController<NSFetchRequestResult> in
        let frc = CoreDataHandler.getTorrentFetchedResultsController(self.context, server: self.server, delegate: self)
        return frc
    }()
    
    // MARK: Load view
    
    override func viewDidLoad()
    {
        context = CoreDataHandler.getManagedObjectContext()
        transmissionClient = TransmissionClient(address: server.address, userName: server.userName, password: server.password)
        
        super.viewDidLoad()
        
        // var error: NSError? = nil
//        if  (fetchedResultsController.performFetch(&error) == false)
//        {
//            print("An error occurred: \(error?.localizedDescription)")
//        }
      do{
        try fetchedResultsController.performFetch()
      }
      catch let error{
        print("An error occurred: \(error.localizedDescription)")
      }


        changeToolbarFontApperance()
        setTransmissionSpeedMode()
        self.clearsSelectionOnViewWillAppear = true
        self.navigationItem.title = server.name
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        enableRefreshAction()
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        if let selectedIndexPath = tableView.indexPathForSelectedRow
        {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        invalidateReloadTimer();
    }
    
    fileprivate func addRefreshButtonToNavigationBar()
    {
        if(self.navigationItem.rightBarButtonItems?.count == 1)
        {
            let refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.refresh, target: self, action: #selector(TorrentsListController.enableRefreshAction))
            self.navigationItem.rightBarButtonItems?.append(refreshButton)
        }
    }
    
    fileprivate func removeRefreshButtonFromNavigationBar()
    {
        if(self.navigationItem.rightBarButtonItems?.count == 2)
        {
           self.navigationItem.rightBarButtonItems?.removeLast()
        }
    }
    
    // MARK: Actions
    
    @IBAction func addNewTorrentAction(_ sender: AnyObject)
    {

      let alert = UIAlertController(title: "Magnet Link", message: "Please enter/paste URL", preferredStyle: UIAlertControllerStyle.alert)
      let sendButton = UIAlertAction(title: "Send", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction) -> Void in
      let linkField = alert.textFields![0] as UITextField
      let linkURL = URL(string: linkField.text!)
      
      self.transmissionClient.addTorrent(linkURL!, isExternal:true, onCompletion: { (error) -> Void in
          if(error != nil)
          {
            NotificationHandler.showError("Error", message: error!.localizedDescription)
          }
          else
          {
            NotificationHandler.showSuccess("Success", message: "Torrent was added")
          }
        })
      
      
      })
      let pasteButton = UIAlertAction(title: "Paste + Send", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction) -> Void in
      let pasteURL = URL(string: UIPasteboard.general.string!)!
      self.transmissionClient.addTorrent(pasteURL, isExternal:true, onCompletion: { (error) -> Void in
          if(error != nil)
          {
            NotificationHandler.showError("Error", message: error!.localizedDescription)
          }
          else
          {
            NotificationHandler.showSuccess("Success", message: "Torrent was added")
          }
        })
      })
      let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {
         (action: UIAlertAction) -> Void in
      
        })
      
      alert.addTextField { (textField: UITextField!) -> Void in
        textField.placeholder = "Paste/Enter Link Here"
      }
      alert.addAction(sendButton)
      alert.addAction(pasteButton)
      alert.addAction(cancelButton)
      
      self.present(alert, animated: true, completion: nil)
        
    }
    
    @objc func enableRefreshAction()
    {
        self.removeRefreshButtonFromNavigationBar()
        
        if(reloadTimer == nil)
        {
            reloadTimer = Timer.scheduledTimer(timeInterval: TimeInterval(4.0), target: self, selector: #selector(TorrentsListController.reloadTimer(_:)), userInfo: nil, repeats: true)
            reloadTimer?.fire()
        }
    }
    

    @IBAction func changeSpeedMode(_ sender: AnyObject)
    {
        if(isAlternativeSpeedModeEnabled)
        {
            transmissionClient.setNormalTransmissionSpeed({ (error) -> Void in
                self.setTransmissionSpeedMode()
            })
        }
        else
        {
            transmissionClient.setAlternativeTransmissionSpeed({ (error) -> Void in
                self.setTransmissionSpeedMode()
            })
        }
    }
    
    fileprivate func invalidateReloadTimer()
    {
        reloadTimer?.invalidate()
        reloadTimer = nil
    }
    
    fileprivate func changeToolbarFontApperance()
    {
        let toolbarFontAttributes = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 13.0)]
        downloadToolbarOutlet.setTitleTextAttributes(toolbarFontAttributes, for: UIControlState())
        uploadToolbarOutlet.setTitleTextAttributes(toolbarFontAttributes, for: UIControlState())
    }
    
    fileprivate func setTransmissionSpeedMode()
    {
      SwiftLoader.show(title: "Loading...", true)
        transmissionClient.getTransmissionSessionInformation { (transmissionSession, error) -> Void in
            
            SwiftLoader.hide()
            if(error != nil)
            {
                NotificationHandler.showError("Error", message: error!.localizedDescription)
            }
            else
            {
                self.isAlternativeSpeedModeEnabled = transmissionSession.altSpeedEnabled
                self.setTransmissionSpeedModeIcon()
            }
        }
    }
    
    fileprivate func setTransmissionSpeedModeIcon()
    {
        DispatchQueue.main.async {
            if(self.isAlternativeSpeedModeEnabled)
            {
                self.speedModeOutlet.image = UIImage(named: "turtle")
            }
            else
            {
                self.speedModeOutlet.image = UIImage(named: "rabbit")
            }
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        DispatchQueue.main.async {
            self.refreshRates()
            self.tableView.endUpdates()
        }
    }
    
    fileprivate func refreshRates()
    {
        var downloadValue = FormatHandler.formatSizeUnits(self.rateDownload)
        var uploadValue = FormatHandler.formatSizeUnits(self.rateUpload)
        self.downloadToolbarOutlet.title = "\(downloadValue)/s"
        self.uploadToolbarOutlet.title = "\(uploadValue)/s"
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType)
    {
        DispatchQueue.main.async {
            switch(type) {
                case NSFetchedResultsChangeType.insert:
                    self.tableView.insertSections(IndexSet(integer: sectionIndex), with: UITableViewRowAnimation.fade)
                    break;
                case NSFetchedResultsChangeType.delete:
                    self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: UITableViewRowAnimation.fade)
                    break;
                default:
                    break
            }
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?)
    {
        DispatchQueue.main.async {
            var tableView = self.tableView
            
            switch(type)
            {
                case NSFetchedResultsChangeType.insert:
                  tableView?.insertRows(at: (NSArray(object: newIndexPath) as! [IndexPath]), with: UITableViewRowAnimation.fade)
              
                  
                  
                  /*"""tableView?.insertRowsAtIndexPaths((((((((((NSArray(object: newIndexPath!) as? [AnyObject]) as [AnyObject]) as [AnyObject]) as [AnyObject]) as [AnyObject]) as [AnyObject]) as [AnyObject]) as [AnyObject]) as [AnyObject]) as [AnyObject], withRowAnimation: UITableViewRowAnimation.Fade)""" */
                    break;

                case NSFetchedResultsChangeType.delete:
                  tableView?.deleteRows(at: (NSArray(object: indexPath) as! [IndexPath]), with: UITableViewRowAnimation.fade)
                    break;

                case NSFetchedResultsChangeType.update:

                    var cell = tableView?.cellForRow(at: indexPath!) as? TorrentsCell
                    
                    if(cell != nil)
                    {
                        let torrent = self.fetchedResultsController.object(at: indexPath!) as! Torrent
                        cell!.setTorrent(torrent)
                    }
                    break;

                case NSFetchedResultsChangeType.move:
                    tableView?.deleteRows(at: (NSArray(object: indexPath) as! [IndexPath]), with: UITableViewRowAnimation.fade)
                    tableView?.insertRows(at: (NSArray(object: newIndexPath) as! [IndexPath]), with: UITableViewRowAnimation.fade)
                    break;
            }
        }
    }
    
    @objc func reloadTimer(_ timer:Timer)
    {
        if(!isDuringRequest)
        {
            transmissionClient.getTorrents(torrentsLoadedCallback)
        }
    }
    
    func torrentsLoadedCallback(_ torrentInformations:[TorrentInformation]!, error:NSError?)
    {
        if(error != nil)
        {
            self.invalidateReloadTimer();
            DispatchQueue.main.async {
                self.addRefreshButtonToNavigationBar()
                NotificationHandler.showError("Error", message: error!.localizedDescription)
            }
        }
        else
        {
            synchronizeWithCoreData(torrentInformations)
        }
        
        isDuringRequest = false
    }
    
    fileprivate func synchronizeWithCoreData(_ torrentInformations:[TorrentInformation]!)
    {
        var torrentsFromCoreData = fetchedResultsController.fetchedObjects as! [Torrent]
        rateDownload = 0
        rateUpload = 0
        
        for torrentFromServer in torrentInformations
        {
            rateDownload += torrentFromServer.rateDownload
            rateUpload += torrentFromServer.rateUpload
            
            var wasSynchronized = false
            for torrentFromCoreData in torrentsFromCoreData
            {
                if(torrentFromServer.hashString == torrentFromCoreData.hashString)
                {
                    torrentFromCoreData.synchronizeData(torrentFromServer)
                    wasSynchronized = true
                    break
                }
            }
            
            if(!wasSynchronized)
            {
                var newTorrent = CoreDataHandler.createTorrentEntity(server, managedContext: context)
                newTorrent.synchronizeData(torrentFromServer)
            }
        }
        
        for torrentFromCoreData in torrentsFromCoreData
        {
            var isExist = false
            for torrentFromServer in torrentInformations
            {
                if(torrentFromServer.hashString == torrentFromCoreData.hashString)
                {
                    isExist = true
                    break
                }
            }
            
            if(!isExist)
            {
                context.delete(torrentFromCoreData)
            }
        }
        
        CoreDataHandler.save(context)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        if let sections = fetchedResultsController.sections
        {
            return sections.count
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let sections = fetchedResultsController.sections
        {
            let currentSection = sections[section] 
            return currentSection.numberOfObjects
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TorrentCell", for: indexPath) as! TorrentsCell
        let torrent = fetchedResultsController.object(at: indexPath) as! Torrent
        
        cell.setTorrent(torrent)
        
        return cell
    }
        
    // MARK: - Navigation
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        
    }
    
    //override func tableView(_ tableView: UITableView, editActionsForRowAtIndexPath indexPath: IndexPath) -> [AnyObject]?
  override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        let torrent = self.fetchedResultsController.object(at: indexPath) as! Torrent

        var runAction = torrent.isPaused ? createReasumeAction(torrent, tableView: tableView) : createPauseAction(torrent, tableView: tableView)
        var deleteAction = createDeleteAction(torrent, tableView: tableView)
        
        return [deleteAction, runAction]
    }
    
    fileprivate func createReasumeAction(_ torrent:Torrent, tableView: UITableView) -> UITableViewRowAction
    {
        var runAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Resume", handler: { (action, indexPath) -> Void in
            self.transmissionClient.reasumeTorrent(torrent.id, onCompletion: { (error) -> Void in
                self.reasumeAction(torrent, error: error)
            })
            
            tableView.setEditing(false, animated: true)
        })
        
        runAction.backgroundColor = ColorsHandler.getGrayColor()
        return runAction
    }
    
    fileprivate func reasumeAction(_ torrent:Torrent, error:NSError?)
    {
        DispatchQueue.main.async {
            if(error != nil)
            {
                NotificationHandler.showError("Error", message: error!.localizedDescription)
                return
            }
            
            torrent.status = TorrentStatusEnum.downloading.rawValue
            CoreDataHandler.save(self.context)
        }
    }
    
    fileprivate func createPauseAction(_ torrent:Torrent, tableView: UITableView) -> UITableViewRowAction
    {
        var runAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Pause" , handler: { (action:UITableViewRowAction!, indexPath:IndexPath!) -> Void in
            self.transmissionClient.pauseTorrent(torrent.id, onCompletion: { (error) -> Void in
                self.pauseAction(torrent, error: error)
            })
            
            tableView.setEditing(false, animated: true)
        })
        
        runAction.backgroundColor = ColorsHandler.getGrayColor()
        return runAction
    }
    
    fileprivate func pauseAction(_ torrent:Torrent, error:NSError?)
    {
        DispatchQueue.main.async {
            if(error != nil)
            {
                NotificationHandler.showError("Error", message: error!.localizedDescription)
            }
            
            torrent.status = TorrentStatusEnum.paused.rawValue
            CoreDataHandler.save(self.context)
        }
    }
    
    fileprivate func createDeleteAction(_ torrent:Torrent, tableView: UITableView) -> UITableViewRowAction
    {
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete" , handler: { (action:UITableViewRowAction!, indexPath:IndexPath!) -> Void in
            self.createDeleteActionSheet(torrent)
            tableView.setEditing(false, animated: true)
        })

        return deleteAction
    }
    
    fileprivate func createDeleteActionSheet(_ torrent:Torrent)
    {
        torrentToDelete = torrent
        let actionSheet = UIActionSheet(title: "Choose delete method", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle:nil, otherButtonTitles: "Delete torrent", "Delete torrent and data")
        actionSheet.show(in: self.view)
    }
    
    func actionSheet(_ actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int)
    {
        if(buttonIndex == deleteTorrentButtonIndex)
        {
            self.transmissionClient.removeTorrent(self.torrentToDelete!.id, deleteLocalData: false, onCompletion: { (error) -> Void in
                self.deleteAction(self.torrentToDelete!, error: error)
            })
        }
        else if(buttonIndex == deleteTorrentWitDataButtonIndex)
        {
            self.transmissionClient.removeTorrent(self.torrentToDelete!.id, deleteLocalData: true, onCompletion: { (error) -> Void in
                self.deleteAction(self.torrentToDelete!, error: error)
            })
        }
    }
    
    fileprivate func deleteAction(_ torrent:Torrent, error:NSError?)
    {
        DispatchQueue.main.async {
            if(error != nil)
            {
                NotificationHandler.showError("Error", message: error!.localizedDescription)
            }
            
            torrent.status = TorrentStatusEnum.deleting.rawValue
            CoreDataHandler.save(self.context)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if(segue.identifier == "PreferencesSegue")
        {
            let destinationViewController = segue.destination as! UINavigationController
            let preferencesController = destinationViewController.viewControllers.first as! PreferencesController
            preferencesController.server = server
        }
    }
}
