//
//  ClassDeclSyntax+.swift
//  
//
//  Created by p-x9 on 2023/05/28.
//  
//

import Foundation
import SwiftSyntax

extension ClassDeclSyntax {
    var resolvedIdentifier: TokenSyntax {
        var parentIdentifiers = [TokenSyntax]()
        var this: Syntax? = self.as(Syntax.self)

        while this?.hasParent ?? false {
            guard let current = this,
                  let parent = current.parent else {
                fatalError()
            }

            if let node = parent.as(StructDeclSyntax.self) {
                parentIdentifiers.append(node.identifier)
            } else if let node = parent.as(ClassDeclSyntax.self) {
                parentIdentifiers.append(node.identifier)
            } else if let node = parent.as(EnumDeclSyntax.self) {
                parentIdentifiers.append(node.identifier)
            } else if var _ = parent.as(ExtensionDeclSyntax.self) {
                // TODO: implement
            }

            this = current.parent
        }

        if parentIdentifiers.isEmpty {
            return identifier
        }

        let resolved = parentIdentifiers
            .reversed()
            .map { $0.withoutTrivia() }
            .map(\.text)
            .joined(separator: ".")

        return .identifier(resolved + "." + identifier.text)
    }
}
