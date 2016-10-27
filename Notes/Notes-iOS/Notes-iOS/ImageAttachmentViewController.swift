//
//  ImageAttachmentViewController.swift
//  Notes
//
//  Created by Jonathon Manning on 27/08/2015.
//  Copyright © 2015 Jonathon Manning. All rights reserved.
//

import UIKit

// BEGIN image_view_controller_definition
class ImageAttachmentViewController: UIViewController, AttachmentViewer {
// END image_view_controller_definition
    
    // BEGIN image_vc_outlet
    @IBOutlet weak var imageView : UIImageView?
    // END image_vc_outlet
    
    // BEGIN image_vc_attachmentviewer
    var attachmentFile : FileWrapper?
    
    var document : Document?
    // END image_vc_attachmentviewer
    
    // BEGIN filter_buttons_property
    @IBOutlet var filterButtons: [UIButton]!
    // END filter_buttons_property
    
    // BEGIN view_did_load_image
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // If we have data, and can make an image out of it...
        if let data = attachmentFile?.regularFileContents,
            let image = UIImage(data: data) {
            // Set the image
            self.imageView?.image = image
              
            // BEGIN view_did_load_image_filter_support
            prepareFilterPreviews()
            // END view_did_load_image_filter_support
        }
    }
    // END view_did_load_image
    
    var filteredImages : [UIImage] = []
    
    // BEGIN prepare_filter_previews
    func prepareFilterPreviews() {
        
        let filters : [CIFilter?] = [
            CIFilter(name: "CIPhotoEffectChrome"),
            CIFilter(name: "CIPhotoEffectNoir"),
            CIFilter(name: "CIPhotoEffectInstant"),
        ]
        
        guard let image = self.imageView?.image else {
            return
        }
        
        let context = CIContext(options: nil)
        
        for (number, filter) in filters.enumerated() {
            
            let button = filterButtons[number]
            
            let unprocessedImage = CIImage(image: image)
            
            filter?.setValue(unprocessedImage, forKey: kCIInputImageKey)
            
            if let processedCIImage =
                filter?.value(forKey: kCIOutputImageKey) as? CIImage{
                    
                    // Render the result into a CGImage
                let image = context.createCGImage(processedCIImage,
                    from: CGRect(origin: CGPoint.zero, size: image.size))
                    
                button.setImage(UIImage(cgImage: image!),
                                for: UIControlState())
            }
        }
    }
    // END prepare_filter_previews

    // BEGIN show_filtered_image
    @IBAction func showFilteredImage(_ sender: UIButton) {
        
        self.imageView?.image = sender.image(for: UIControlState())
        self.imageView?.contentMode = .scaleAspectFit
        
    }
    // END show_filtered_image
    
    // BEGIN image_attachment_share_image
    @IBAction func shareImage(_ sender: UIBarButtonItem) {
        
        // Ensure that we're actually showing an image
        guard let image = self.imageView?.image else {
            return
        }
        
        let activityController = UIActivityViewController(
            activityItems: [image], applicationActivities: nil)
        
        // If we are being presented in a window that's a Regular width,
        // show it in a popover (rather than the default modal)
        if UIApplication.shared.keyWindow?.traitCollection
            .horizontalSizeClass == UIUserInterfaceSizeClass.regular {
            activityController.modalPresentationStyle = .popover
            
            activityController.popoverPresentationController?
                .barButtonItem = sender
        }
        
        self.present(activityController, animated: true,
            completion: nil)
        
    }
    // END image_attachment_share_image

}
