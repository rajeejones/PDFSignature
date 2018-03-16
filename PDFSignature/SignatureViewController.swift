//
//  SignatureViewController.swift
//  PDFSignature
//
//  Created by Rajee Jones on 3/12/18.
//  Copyright © 2018 rajeejones. All rights reserved.
//

import UIKit
import TouchDraw

class SignatureViewController: UIViewController {

    @IBOutlet weak var touchDrawView: TouchDrawView!
    
    var previousViewController: UIViewController?
    var signatureExport: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        touchDrawView.delegate = self
        touchDrawView.setWidth(3.0)
        
        self.navigationController?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        touchDrawView.clearDrawing()
        signatureExport = nil
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func trashButtonPressed(_ sender: Any) {
        touchDrawView.clearDrawing()
    }
    
    @IBAction func attachSignatureButtonPressed(_ sender: Any) {
        if touchDrawView.exportStack().count > 0 {
            self.signatureExport = touchDrawView.exportDrawing()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
 

}

extension SignatureViewController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController == self.previousViewController {
            let vc = viewController as! ViewController
            vc.signatureImage = signatureExport
        }
    }
    
}

extension SignatureViewController: TouchDrawViewDelegate {

}
