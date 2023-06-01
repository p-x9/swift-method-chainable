//
//  ModifySyntaxVisiter.swift
//  
//
//  Created by p-x9 on 2023/05/28.
//  
//

import Foundation
import SwiftSyntax

class ModifySyntaxVisiter: SyntaxVisitor {
    var imports = [ImportDeclSyntax]()
    var structs = [StructDeclSyntax]()
    var classes = [ClassDeclSyntax]()

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        structs.append(node)
        return super.visit(node)
    }

    override func visit(_ node: ImportDeclSyntax) -> SyntaxVisitorContinueKind {
        imports.append(node)
        return super.visit(node)
    }

    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        classes.append(node)
        return super.visit(node)
    }
}
