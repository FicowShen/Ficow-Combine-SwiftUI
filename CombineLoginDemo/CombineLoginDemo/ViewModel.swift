//
//  ViewModel.swift
//  CombineLoginDemo
//
//  Created by FicowShen on 2020/8/27.
//  Copyright © 2020 ficow. All rights reserved.
//

import Foundation

/// Protocol that all ViewModels must conform to perform required transformations.
public protocol ViewModel {
    /// Defined inputs from the view controller that will be used to trigger transformations.
    associatedtype Input
    /// Transformed data or actions that the UI can use.
    associatedtype Output
    
    /**
     Performs transformation of the defined data/action Input to Output for the UI to use.
     
     - Parameters:
     - input: Used to trigger transformations.
     
     - Returns: Output for transformed data or actions.
     */
    func transform(input: Input) -> Output
}
