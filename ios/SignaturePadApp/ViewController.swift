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
        let signaturePad = view as! SignaturePad
        signaturePad.onUpdateSignature = onUpdateSignature
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func onUpdateSignature (count: CGFloat, length: CGFloat) {
        print("Signature Update count=\(count), length=\(length)")
    }

}

