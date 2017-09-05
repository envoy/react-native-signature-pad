//
//  ViewController.swift
//  SignaturePadApp
//
//  Created by Fang-Pen Lin on 8/30/17.
//  Copyright © 2017 Envoy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let pad = (view as! SignaturePad)
        // pad.debug = ProcessInfo.processInfo.environment["DEBUG"] == "1"
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

