//
//  ViewController.swift
//  MusicLibraryDemo
//
//  Created by Jayesh Mardiya on 11/09/19.
//  Copyright © 2019 Samanvay. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var imageLibraryPic: UIImageView!
    @IBOutlet weak var labelArtist: UILabel!
    @IBOutlet weak var labelAlbum: UILabel!
    @IBOutlet weak var labelMusic: UILabel!
    
    //MediaPlayer
    var player: MPMusicPlayerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        player = MPMusicPlayerController.applicationMusicPlayer
        player.beginGeneratingPlaybackNotifications()
    }
}

// MARK:- Action Methods -
extension ViewController {
    
    /// Open Media Picker
    @IBAction func buttonOpenMediaPickerPressed(_ sender: Any) {
        
        // MPMediaPickerController
        let picker = MPMediaPickerController()
        
        // Delegate
        picker.delegate = self
        
        // Single item selection
        picker.allowsPickingMultipleItems = false
        
        // Set protected assets
        picker.showsItemsWithProtectedAssets = false
        
        // For Cloud items
        picker.showsCloudItems = false
        
        // Show Picker
        present(picker, animated: true, completion: nil)
    }
    
    /// Play Player
    @IBAction func buttonPlayPressed(_ sender: Any) {
        player.play()
    }
    
    /// Pause Player
    @IBAction func buttonPausePressed(_ sender: Any) {
        player.pause()
    }
    
    /// Stop Player
    @IBAction func buttonStopPressed(_ sender: Any) {
        player.stop()
    }
}

// MARK:- MPMediaPickerControllerDelegate -
extension ViewController: MPMediaPickerControllerDelegate {
    
    /// Called when an item has been selected in the media item picker
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        
        // Stop player
        player.stop()
        
        // The selected song information is in mediaItemCollection, so set this in the player
        player.setQueue(with: mediaItemCollection)
        
        // Display the first song information from the selected song
        if let mediaItem = mediaItemCollection.items.first {
            self.updateSongInformationUI(mediaItem: mediaItem)
        }
        
        // dismiss picker
        dismiss(animated: true, completion: nil)
    }
    
    
    /// called if the selection is canceled
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        
        // dismiss picker
        dismiss(animated: true, completion: nil)
    }
}

// MARK:- Private Extension -
private extension ViewController {
    
    /// Display song information
    func updateSongInformationUI(mediaItem: MPMediaItem) {
        
        // music information
        labelArtist.text = mediaItem.artist ?? "Unknown artist"
        labelAlbum.text = mediaItem.albumTitle ?? "Unknown album"
        labelMusic.text = mediaItem.title ?? "Unknown song"
        
        // Download song
        let songUrl = mediaItem.value(forProperty: MPMediaItemPropertyAssetURL) as! URL
        print(songUrl)
        
        // get file extension andmime type
        let str = songUrl.absoluteString
        let str2 = str.replacingOccurrences( of : "ipod-library://item/item", with: "")
        let arr = str2.components(separatedBy: "?")
        var mimeType = arr[0]
        mimeType = mimeType.replacingOccurrences( of : ".", with: "")
        
        let exportSession = AVAssetExportSession(asset: AVAsset(url: songUrl), presetName: AVAssetExportPresetAppleM4A)
        exportSession?.shouldOptimizeForNetworkUse = true
        exportSession?.outputFileType = AVFileType.m4a
        
        //save it into your local directory
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // Save as title
        let outputURL = documentURL.appendingPathComponent(mediaItem.title!+".wav")
        print(outputURL.absoluteString)
        
        // Delete Existing file
        do {
            try FileManager.default.removeItem(at: outputURL)
        } catch let error as NSError {
            print(error.debugDescription)
        }
        
        exportSession?.outputURL = outputURL
        exportSession?.exportAsynchronously(completionHandler: { () -> Void in
            
            if exportSession!.status == AVAssetExportSession.Status.completed {
                print("Export Successfull")
            }
            self.dismiss(animated: true, completion: nil)
        })
        
        // Artwork display
        if let artwork = mediaItem.artwork {
            let image = artwork.image(at: imageLibraryPic.bounds.size)
            imageLibraryPic.image = image
        } else {
            // When there is no artwork (This time grayed out)
            imageLibraryPic.image = nil
            imageLibraryPic.backgroundColor = UIColor.gray
        }
    }
}
