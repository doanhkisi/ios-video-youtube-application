//
//  CreateNewPlaylistViewController.swift
//  TubeTrends
//
//  Created by Vũ Trung Thành on 2/17/16.
//  Website: https://v2t.mobi
//  Copyright © 2016 V2T Multimedia. All rights reserved.
//

import UIKit

class CreateNewPlaylistViewController: UIViewController {
    
    var cancelButtonTappedHandler: (Void -> Void)?
    var addButtonTappedHandler: (Void -> Void)?
    var createdPlaylistHandler: (Items -> Void)?

    @IBOutlet weak var playlistNameTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playlistNameTextField.becomeFirstResponder()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonTapped(sender: UIButton) {
        self.view.endEditing(true)
        cancelButtonTappedHandler?()
    }

    @IBAction func addButtonTapped(sender: UIButton) {
        self.view.endEditing(true)
        if let playlistName = playlistNameTextField.text?.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet()
            ) {
                if playlistName != "" {
                    createNewPlaylist(playlistName)
                } else {
                    playlistNameTextField.highlighted = true
                    playlistNameTextField.becomeFirstResponder()
                }
        } else {
            playlistNameTextField.highlighted = true
            playlistNameTextField.becomeFirstResponder()
        }
        addButtonTappedHandler?()
    }
    
    private func createNewPlaylist(playlistName: String) {
        let playlist = Items()
        
        playlist.name = playlistName
        
        try! TubeTrends.realm.write({
            TubeTrends.realm.add(playlist)
            createdPlaylistHandler?(playlist)
        })
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
