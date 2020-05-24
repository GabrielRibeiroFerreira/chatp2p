//
//  ViewController.swift
//  chatp2p
//
//  Created by Gabriel Ferreira on 23/05/20.
//  Copyright © 2020 Gabriel Ferreira. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ChatViewController: UIViewController, MCSessionDelegate, MCBrowserViewControllerDelegate {
    var peerID : MCPeerID!
    var mcSession : MCSession!
    var mcAdvertiserAssistant : MCAdvertiserAssistant!
    
    @IBOutlet weak var chatTextView: UITextView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var connectionButton: UIBarButtonItem!
    
    var sendMsg : String!
    var receiveMsg : String!
    var hosting : Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.peerID = MCPeerID(displayName: UIDevice.current.name)
        self.mcSession = MCSession(peer: self.peerID, securityIdentity: nil, encryptionPreference: .required)
        self.mcSession.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.removeKeyboard(_:)))
        self.view.addGestureRecognizer(tap)
        
        self.sendButton.isEnabled = false
        self.chatTextView.isEditable = false
        
        self.hosting = false
    }

    @objc func removeKeyboard(_ sender : UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    //MARK: -Message
    @IBAction func sendMessage(_ sender: Any) {
        if self.inputTextField.text != "" {
            self.sendMsg = "\n\(self.peerID.displayName): \(self.inputTextField!)\n"
            
            let message = sendMsg.data(using: .utf8, allowLossyConversion: false)
            
            do {
                try self.mcSession.send(message! , toPeers: self.mcSession.connectedPeers, with: .reliable)
            } catch {
                print("error sending message")
            }
            
            self.chatTextView.text = self.chatTextView.text + "\nMe: \(self.inputTextField.text!)"
            self.inputTextField.text = ""
        } else {
            let emptyAlert = UIAlertController(title: "you have not entered any text", message: nil, preferredStyle: .alert)
            
            emptyAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            
            self.present(emptyAlert, animated: true, completion: nil)
        }
    }
    
    //MARK: -Connection
    @IBAction func connection(_ sender: Any) {
        if self.mcSession.connectedPeers.count == 0 && !hosting {
            let connectActionSheet = UIAlertController(title: "our chat", message: "do you wnat to host or join a chat?", preferredStyle: .actionSheet)
            
            connectActionSheet.addAction(UIAlertAction(title: "host chat", style: .default, handler: { (action : UIAlertAction) in
                
                //SEARCH LATER
                self.mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "doest-matter", discoveryInfo: nil, session: self.mcSession)
                self.mcAdvertiserAssistant.start()
                self.hosting = true
                
            }))
            
            connectActionSheet.addAction(UIAlertAction(title: "join chat", style: .default, handler: { (action : UIAlertAction) in
                
                //SEARCH LATER
                let mcBrowser = MCBrowserViewController(serviceType: "oest-matter", session: self.mcSession)
                mcBrowser.delegate = self
                self.present(mcBrowser, animated: true, completion: nil)
                
            }))
            
            connectActionSheet.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
            
            self.present(connectActionSheet, animated: true, completion: nil)
            
        } else if self.mcSession.connectedPeers.count == 0 && hosting {
            let waitActionSheet = UIAlertController(title: "waiting...", message: "waiting for otherto join the chat", preferredStyle: .actionSheet)
            waitActionSheet.addAction(UIAlertAction(title: "Disconnect", style: .destructive, handler: { (action) in
                
                self.mcSession.disconnect()
                self.hosting = false
                
            }))
            
            waitActionSheet.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
            
            self.present(waitActionSheet, animated: true, completion: nil)
            
        } else {
            let disconnectActionSheet = UIAlertController(title: "are you sure you want to disconnect", message: nil, preferredStyle: .actionSheet)
            disconnectActionSheet.addAction(UIAlertAction(title: "Disconnect", style: .destructive, handler: { (action) in
                
                self.mcSession.disconnect()
                
            }))
            
            disconnectActionSheet.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
            
            self.present(disconnectActionSheet, animated: true, completion: nil)
        }
    }
    
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print("connected: \(self.peerID.displayName)")
        case .connecting:
            print("connecting: \(self.peerID.displayName)")
        case .notConnected:
            print("not connected: \(self.peerID.displayName)")
        @unknown default:
            print("error")
        }
        
        self.sendButton.isEnabled = (self.mcSession.connectedPeers.count != 0)
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            self.receiveMsg = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)! as String
            self.chatTextView.text = self.chatTextView.text + self.receiveMsg
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
    }
    
}

