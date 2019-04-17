//
//  ViewController.swift
//  Example
//
//  Created by Guillaume Aquilina on 3/27/19.
//  Copyright © 2019 John Paul Concierge. All rights reserved.
//

import UIKit
import CasperText

class ViewController: UIViewController {

    @IBOutlet var fields: [CasperTextField]!

    override func viewDidLoad() {
        super.viewDidLoad()

        for f in fields {
            f.addTarget(self, action: #selector(ViewController.didEndOnExit(sender:)),
                        for: .editingDidEndOnExit)
            f.returnKeyType = .next
        }
        fields.last?.returnKeyType = .done
    }

    @IBAction func didEndOnExit(sender: CasperTextField) {
        let index = fields.firstIndex(of: sender)!
        if index == fields.count - 1 {
            _ = fields[index].resignFirstResponder()
        } else {
            _ = fields[index + 1].becomeFirstResponder()
        }
    }


}

