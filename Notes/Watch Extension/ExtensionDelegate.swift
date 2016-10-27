//
//  ExtensionDelegate.swift
//  Watch Extension
//
//  Created by Jon Manning on 3/11/2015.
//  Copyright © 2015 Jonathon Manning. All rights reserved.
//

import WatchKit
// BEGIN watch_imports
import WatchConnectivity
// END watch_imports

// BEGIN watch_session_manager
class SessionManager : NSObject, WCSessionDelegate {
    
    
    @available(watchOSApplicationExtension 2.2, *)
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        // Session activated.
    }

    
    // BEGIN watch_session_manager_noteinfo
    struct NoteInfo {
        var name : String
        var URL : Foundation.URL?
        
        init(dictionary:[String:AnyObject]) {
            
            let name
                = dictionary[WatchMessageContentNameKey] as? String
                    ?? "(no name)"
            
            self.name = name
            
            if let URLString = dictionary[WatchMessageContentURLKey] as? String {
                self.URL = Foundation.URL(string: URLString)
            }
            
        }
    }
    // END watch_session_manager_noteinfo
    
    // BEGIN watch_session_manager_noteinfo_list
    var notes : [NoteInfo] = []
    // END watch_session_manager_noteinfo_list
    
    
    // BEGIN watch_session_manager_singleton
    static let sharedSession = SessionManager()
    // END watch_session_manager_singleton
    
    // BEGIN watch_session_manager_singleton_init
    var session : WCSession { return WCSession.default() }
    
    override init() {
        super.init()
        session.delegate = self
        session.activate()
    }
    // END watch_session_manager_singleton_init
    
    // BEGIN watch_session_manager_create_note
    func createNote(_ text:String,
         completionHandler: @escaping ([NoteInfo], Error?)->Void) {
        
        let message = [
            WatchMessageTypeKey : WatchMessageTypeCreateNoteKey,
            WatchMessageContentTextKey : text
        ]
        
        session.sendMessage(message, replyHandler: {
            reply in
            
            self.updateLocalNoteListWithReply(reply)
            
            completionHandler(self.notes, nil)
            
        }, errorHandler: {
            error in
            
            completionHandler([], error)
        })
    }
    // END watch_session_manager_create_note
    
    // BEGIN watch_session_manager_update_local_note_list
    func updateLocalNoteListWithReply(_ reply:[String:Any]) {
        
        if let noteList = reply[WatchMessageContentListKey]
            as? [[String:AnyObject]] {
            
            // Convert all dictionaries to notes
            self.notes = noteList.map({ (dict) -> NoteInfo in
                return NoteInfo(dictionary: dict)
            })
            
        }
        print("Loaded \(self.notes.count) notes")
    }
    // END watch_session_manager_update_local_note_list
    
    // BEGIN watch_session_manager_update_list
    func updateList(_ completionHandler: @escaping ([NoteInfo], NSError?)->Void) {
        
        let message = [
            WatchMessageTypeKey : WatchMessageTypeListAllNotesKey
        ]
        
        session.sendMessage(message, replyHandler: {
            reply in
            
            self.updateLocalNoteListWithReply(reply as [String : AnyObject])
            
            completionHandler(self.notes, nil)
            
        }, errorHandler: { error in
            print("Error!")
            completionHandler([], error as NSError?)
                
        })
    }
    // END watch_session_manager_update_list
    
    // BEGIN watch_session_manager_load_note
    func loadNote(_ noteURL: URL, completionHandler: @escaping (String?, Error?) -> Void) {
        
        let message = [
            WatchMessageTypeKey: WatchMessageTypeLoadNoteKey,
            WatchMessageContentURLKey: noteURL.absoluteString
        ]
        
        session.sendMessage(message, replyHandler: {
            reply in
            
            let text = reply[WatchMessageContentTextKey] as? String
            
            completionHandler(text, nil)
        },
        errorHandler: { error in
            completionHandler(nil, error)
        })
        
    }
    // END watch_session_manager_load_note
    
    
}
// END watch_session_manager

class ExtensionDelegate: NSObject, WKExtensionDelegate {

    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        
        
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

}
