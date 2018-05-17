//
//  GCDBlackBox.swift
//  OntheMap
//
//  Created by Chhaya Tiwari on 4/30/18.
//  Copyright © 2018 ChhayaTiwari. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
