//
//  Functions.swift
//  MyLocations
//
//  Created by Maryna Bolotska on 17/10/23.
//

import Foundation


func afterDelay(_ seconds: Double, run: @escaping () -> Void) {
  DispatchQueue.main.asyncAfter(
    deadline: .now() + seconds,
    execute: run)
}
