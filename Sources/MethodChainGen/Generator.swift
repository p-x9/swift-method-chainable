//
//  Generator.swift
//  
//
//  Created by p-x9 on 2023/05/29.
//  
//

import Foundation
import SwiftParser
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftBasicFormat

class Generator {

    private let fileManager: FileManager = .default

    private var header: String {
    """
    // Generated by `MethodChainGen`
    // https://github.com/p-x9/swift-method-chainable
    //
    // DO NOT EDIT THIS FILE
    // swiftlint:disable all

    """
    }

    let inputURL: URL
    let outputURL: URL
    let overwrite: Bool

    public init(inputURL: URL, outputURL: URL, overwrite: Bool = false) {
        self.inputURL = inputURL
        self.outputURL = outputURL
        self.overwrite = overwrite
    }

    public func generate() throws {
        try generate(
            forDirectory: inputURL,
            outputDirectory: outputURL
        )
    }
}

extension Generator {
    private func generate(forDirectory url: URL, outputDirectory: URL) throws {
        let contents = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
        try contents.forEach {
            if $0.pathExtension == "swift" {
                try generate(forFile: $0, outputDirectory: outputDirectory)
            } else if fileManager.isDirectory($0) {
                let output = outputDirectory.appendingPathComponent($0.lastPathComponent, isDirectory: true)
                try generate(forDirectory: $0, outputDirectory: output)
            }
        }

    }

    private func generate(forFile url: URL, outputDirectory: URL) throws {
        let outputURL = outputDirectory.appendingPathComponent(url.lastPathComponent)

        if !overwrite && fileManager.fileExists(atPath: outputURL.path) {
            print("skip: \(url)")
            return
        } else {
            print("generate: \(url)")
        }

        let data = try Data(contentsOf: url)
        guard let string = String(data: data, encoding: .utf8) else {
            return
        }
        let syntax = SwiftParser.Parser.parse(source: string)
        let visitor = ModifySyntaxVisiter(viewMode: .sourceAccurate)
        visitor.walk(syntax)

        var generatedExtensions = visitor.structs.compactMap {
            var generated = generate(for: $0)
            generated?.leadingTrivia = .newlines(2)
            return generated
        }
        generatedExtensions += visitor.classes.compactMap {
            var generated = generate(for: $0)
            generated?.leadingTrivia = .newlines(2)
            return generated
        }

        let importBlockItems = visitor.imports
            .map { $0.withoutTrivia() }
            .map { CodeBlockItem(item: .init($0)) }


        var codeBlockItems = importBlockItems + generatedExtensions.map { CodeBlockItem(item: .init($0)) }

        codeBlockItems[safe: 0]?.leadingTrivia = .docLineComment(header).appending(.newlines(1))

        let sourceSyntax = SourceFileSyntax(
            statements: CodeBlockItemListSyntax(codeBlockItems),
            eofToken: .eof
        ).formatted()

        try fileManager.createDirectoryIfNotExisted(
            at: outputDirectory,
            withIntermediateDirectories: true
        )

        try sourceSyntax.description.write(to: outputURL, atomically: true, encoding: .utf8)
    }
}

// MARK: - Generate with Swift Syntax
extension Generator {
    private func generate(for syntax: StructDeclSyntax) -> ExtensionDeclSyntax? {
        let functions = syntax.members.members
            .compactMap {
                $0.decl.as(FunctionDeclSyntax.self)
            }
            .filter {
                $0.signature.output == nil || $0.signature.output == .init(returnType: SimpleTypeIdentifier(name: .identifier("Void")))
            }

        if functions.isEmpty {
            return nil
        }

        var newFunctions = functions

        for (i, function) in functions.enumerated() {
            let codeBlockItemList = CodeBlockItemListSyntax {
                VariableDeclSyntax(
                    letOrVarKeyword: .var,
                    bindings: PatternBindingListSyntax {
                        PatternBindingSyntax(
                            pattern: IdentifierPatternSyntax(identifier: .identifier("new")),
                            initializer: InitializerClauseSyntax(value: IdentifierExprSyntax(identifier: .selfKeyword()))
                        )
                    }
                )
                function.callWithSameArguments(
                    calledExpression: MemberAccessExprSyntax(
                        base: IdentifierExprSyntax(identifier: .identifier("new")), dot: .period, name: function.identifier.withoutTrivia()
                    )
                )

                ReturnStmt(expression: IdentifierExpr(identifier: .identifier("new")))
            }

            var currentAttributes = newFunctions[i].attributes ?? AttributeListSyntax([])
            newFunctions[i].attributes = currentAttributes.appending(.attribute(._disfavoredOverload))

            newFunctions[i].funcKeyword = .funcKeyword(leadingTrivia: .newline)
            newFunctions[i].body = CodeBlockSyntax(statements: codeBlockItemList)
            newFunctions[i].signature.output = ReturnClauseSyntax(returnType: SimpleTypeIdentifierSyntax(name: .capitalSelf))

            newFunctions[i] = newFunctions[i].withoutTrivia()

            if i != 0 {
                newFunctions[i].leadingTrivia = .newlines(2)
            }
        }

        let typeIdentifier = SimpleTypeIdentifierSyntax(name: syntax.resolvedIdentifier)

        return ExtensionDeclSyntax(
            extendedType: typeIdentifier,
            members: MemberDeclBlockSyntax(
                members: MemberDeclListSyntax(newFunctions.map { MemberDeclListItem(decl: $0) })
            )
        ).withoutTrivia()
    }

    private func generate(for syntax: ClassDeclSyntax) -> ExtensionDeclSyntax? {
        let functions = syntax.members.members
            .compactMap {
                $0.decl.as(FunctionDeclSyntax.self)
            }
            .filter {
                $0.signature.output == nil || $0.signature.output == .init(returnType: SimpleTypeIdentifier(name: .identifier("Void")))
            }

        if functions.isEmpty {
            return nil
        }

        var newFunctions = functions

        for (i, function) in functions.enumerated() {
            let codeBlockItemList = CodeBlockItemListSyntax {
                function.callWithSameArguments(
                    calledExpression: MemberAccessExprSyntax(
                        base: IdentifierExprSyntax(identifier: .selfKeyword()), dot: .period, name: function.identifier.withoutTrivia()
                    )
                )

                ReturnStmt(expression: IdentifierExpr(identifier: .selfKeyword()))
            }

            var currentAttributes = newFunctions[i].attributes ?? AttributeListSyntax([])
            newFunctions[i].attributes = currentAttributes.appending(.attribute(._disfavoredOverload))

            newFunctions[i].funcKeyword = .funcKeyword(leadingTrivia: .newline)
            newFunctions[i].body = CodeBlockSyntax(statements: codeBlockItemList)
            newFunctions[i].signature.output = ReturnClauseSyntax(returnType: SimpleTypeIdentifierSyntax(name: .capitalSelf))

            let modifiers = newFunctions[i].modifiers?.filter {
                $0.name.withoutTrivia().text != "override"
            } ?? []
            newFunctions[i].modifiers = .init(modifiers)

            newFunctions[i] = newFunctions[i].withoutTrivia()

            if i != 0 {
                newFunctions[i].leadingTrivia = .newlines(2)
            }
        }

        let typeIdentifier = SimpleTypeIdentifierSyntax(name: syntax.resolvedIdentifier)

        return ExtensionDeclSyntax(
            extendedType: typeIdentifier,
            members: MemberDeclBlockSyntax(
                members: MemberDeclListSyntax(newFunctions.map { MemberDeclListItem(decl: $0) })
            )
        ).withoutTrivia()
    }
}
