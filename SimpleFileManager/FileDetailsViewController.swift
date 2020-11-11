//
//  FileDetailsViewController.swift
//  SimpleFileManager
//
//  Created by Надежда Зенкова on 10.11.2020.
//  Copyright © 2020 Надежда Зенкова. All rights reserved.
//

import UIKit

class FileDetailsViewController: UIViewController {
    
    @IBOutlet weak var fileTextView: UITextView! {
        didSet {
            fileTextView.text = fileText
        }
    }
    
    var fileText: String?
    
   // override func viewDidLoad() {
    //    super.viewDidLoad()
        
        
   // }
}
