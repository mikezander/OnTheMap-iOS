//
//  GCD.swift
//  OnTheMap
//
//  Created by Michael Alexander on 6/8/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
