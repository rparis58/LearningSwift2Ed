//
//  DocumentCommon.swift
//  Notes
//
//  Created by Jonathon Manning on 26/08/2015.
//  Copyright © 2015 Jonathon Manning. All rights reserved.
//

import Foundation

// BEGIN document_common
// We can be throwing a lot of errors in this class, and they'll all 
// be in the same error domain and using error codes from the same 
// enum, so here's a little convenience func to save typing and space

// BEGIN error_func
let ErrorDomain = "NotesErrorDomain"

func err(_ code: ErrorCode, _ userInfo:[AnyHashable: Any]? = nil)  -> NSError {
    // Generate an NSError object, using ErrorDomain, and using whatever
    // value we were passed.
    return NSError(domain: ErrorDomain, code: code.rawValue, userInfo: userInfo)
}
// END error_func

// BEGIN document_file_names
// Names of files/directories in the package
enum NoteDocumentFileNames : String {
    ///- The file that contains the text of the document, in
    ///- Rich Text Format.
    case TextFile = "Text.rtf"
    
    ///- The folder that all attachments will be kept in.
    case AttachmentsDirectory = "Attachments"
    
// BEGIN document_file_names_quicklook
    ///- The QuickLook folder.
    case QuickLookDirectory = "QuickLook"

    ///- The QuickLook text file, which goes in the QuickLook directory.
    case QuickLookTextFile = "Preview.rtf"
    
    ///- The QuickLook thumbnail file, which goes in the QuickLook directory.
    case QuickLookThumbnail = "Thumbnail.png"
// END document_file_names_quicklook

// BEGIN location_file_name
    case locationAttachment = "location.json"
// END location_file_name
}
// END document_file_names

// BEGIN preferences_keys
let NotesUseiCloudKey = "use_icloud"
let NotesHasPromptedForiCloudKey = "has_prompted_for_icloud"

// END preferences_keys

/// Things that can go wrong.
// BEGIN error_codes
enum ErrorCode : Int {
    
    /// We couldn't find the document at all.
    case cannotAccessDocument
    
    /// We couldn't access any file wrappers inside this document.
    case cannotLoadFileWrappers
    
    /// We couldn't load the Text.rtf file.
    case cannotLoadText
    
    /// We couldn't access the Attachments folder.
    case cannotAccessAttachments
    
    /// We couldn't save the Text.rtf file.
    case cannotSaveText
    
    /// We couldn't save an attachment.
    case cannotSaveAttachment
}
// END error_codes
// END document_common

// These are constants because otherwise we have way too many ".rawValues"
// in the same place, which is really hard to read
// BEGIN watch_messages
let WatchMessageTypeKey = "msg"
let WatchMessageTypeListAllNotesKey = "list"
let WatchMessageTypeLoadNoteKey = "load"
let WatchMessageTypeCreateNoteKey = "create"

let WatchMessageContentNameKey = "name"
let WatchMessageContentURLKey = "url"
let WatchMessageContentTextKey = "text"
let WatchMessageContentListKey = "list"
// END watch_messages

// Necessary because NSUserActivityDocumentURLKey doesn't exist on watchOS
// BEGIN watch_handoff_key
let WatchHandoffDocumentURL = "watch_document_url_key"
// END watch_handoff_key
