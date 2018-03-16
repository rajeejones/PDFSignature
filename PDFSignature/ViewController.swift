//
//  ViewController.swift
//  PDFSignature
//
//  Created by Rajee Jones on 3/12/18.
//  Copyright © 2018 rajeejones. All rights reserved.
//

import UIKit
import PDFKit

class ImageStampAnnotation: PDFAnnotation {
    
    var image: UIImage!
    
    // A custom init that sets the type to Stamp on default and assigns our Image variable
    init(with image: UIImage!, forBounds bounds: CGRect, withProperties properties: [AnyHashable : Any]?) {
        super.init(bounds: bounds, forType: PDFAnnotationSubtype.stamp, withProperties: properties)
        
        self.image = image
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func draw(with box: PDFDisplayBox, in context: CGContext) {
        
        // Get the CGImage of our image
        guard let cgImage = self.image.cgImage else { return }
        
        // Draw our CGImage in the context of our PDFAnnotation bounds
        context.draw(cgImage, in: self.bounds)
        
    }
}


class ViewController: UIViewController {

    @IBOutlet weak var pdfContainerView: PDFView!
    
    var currentlySelectedAnnotation: PDFAnnotation?
    var signatureImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "PDF Viewer"
        setupPdfView()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let signatureImage = signatureImage, let page = pdfContainerView.currentPage else { return }
        let pageBounds = page.bounds(for: .cropBox)
        let imageBounds = CGRect(x: pageBounds.midX, y: pageBounds.midY, width: 200, height: 100)
        let imageStamp = ImageStampAnnotation(with: signatureImage, forBounds: imageBounds, withProperties: nil)
        page.addAnnotation(imageStamp)
    }

    func setupPdfView() {
        // Download simple pdf document
        if let documentURL = URL(string: "https://blogs.adobe.com/security/SampleSignedPDFDocument.pdf"),
            let data = try? Data(contentsOf: documentURL),
            let document = PDFDocument(data: data) {
            
            // Set document to the view, center it, and set background color
            pdfContainerView.document = document
            pdfContainerView.autoScales = true
            pdfContainerView.backgroundColor = UIColor.lightGray
            
            let panAnnotationGesture = UIPanGestureRecognizer(target: self, action: #selector(didPanAnnotation(sender:)))
            pdfContainerView.addGestureRecognizer(panAnnotationGesture)
            
        }
    }
    
    @objc func didPanAnnotation(sender: UIPanGestureRecognizer) {
        let touchLocation = sender.location(in: pdfContainerView)
        
        guard let page = pdfContainerView.page(for: touchLocation, nearest: true)
            else {
                return
        }
        let locationOnPage = pdfContainerView.convert(touchLocation, to: page)
        
        switch sender.state {
        case .began:
            
            guard let annotation = page.annotation(at: locationOnPage) else {
                return
            }
            
            if annotation.isKind(of: ImageStampAnnotation.self) {
                currentlySelectedAnnotation = annotation
            }
            
        case .changed:
            
            guard let annotation = currentlySelectedAnnotation else {
                return
            }
            let initialBounds = annotation.bounds
            // Set the center of the annotation to the spot of our finger
            annotation.bounds = CGRect(x: locationOnPage.x - (initialBounds.width / 2), y: locationOnPage.y - (initialBounds.height / 2), width: initialBounds.width, height: initialBounds.height)
            
            
            print("move to \(locationOnPage)")
        case .ended, .cancelled, .failed:
            currentlySelectedAnnotation = nil
        default:
            break
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSignatureSegue" {
            if let nextVC = segue.destination as? SignatureViewController {
                nextVC.previousViewController = self
            }
        }
    }
    
}

