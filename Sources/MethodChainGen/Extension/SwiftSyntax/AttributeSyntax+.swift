//
//  AttributeSyntax+.swift
//  
//
//  Created by p-x9 on 2023/06/01.
//  
//

import Foundation
import SwiftSyntax

extension AttributeSyntax {
    static var _disfavoredOverload: Self {
        .init(attributeName: .identifier("_disfavoredOverload"))
    }
}
