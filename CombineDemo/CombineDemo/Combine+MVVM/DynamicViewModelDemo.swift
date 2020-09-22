//
//  DynamicViewModelDemo.swift
//  CombineDemo
//
//  Created by Ficow on 2020/9/21.
//  Copyright © 2020 FicowShen. All rights reserved.
//

import Foundation
import Combine

protocol DynamicViewModel {
    associatedtype Input
    associatedtype Output

    var input: Input { get }
    var output: Output { get }
}
