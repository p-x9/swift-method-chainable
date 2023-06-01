//
//  FunctionDeclSyntax+.swift
//  
//
//  Created by p-x9 on 2023/05/28.
//  
//

import Foundation
import SwiftSyntax

extension FunctionDeclSyntax {
    func callWithSameArguments<C>(calledExpression: C) -> FunctionCallExprSyntax where C: ExprSyntaxProtocol  {
        let params = signature.input.parameterList

        let arguments: [TokenSyntax] = params.map {
            $0.secondName == nil ? $0.firstName : $0.secondName
        }.compactMap { $0 }

        return call(calledExpression: calledExpression, arguments: arguments)
    }

    func call<C>(calledExpression: C, arguments: [TokenSyntax]) -> FunctionCallExprSyntax where C: ExprSyntaxProtocol  {
        let params = signature.input.parameterList

        precondition(arguments.count >= params.count)

        var argumentList: [TupleExprElementSyntax] = params.enumerated().map { i, param in
            var label: TokenSyntax? = param.firstName?.withoutTrivia()
            if label?.rawTokenKind == .wildcardKeyword { label = nil }

            let expression = arguments[i]

            return TupleExprElementSyntax(
                label: label,
                colon: label == nil ? nil : .colon,
                expression: IdentifierExprSyntax(identifier: expression),
                trailingComma: .comma
            )
        }

        argumentList[safe: argumentList.endIndex - 1]?.trailingComma = nil

        return FunctionCallExprSyntax(
            calledExpression: calledExpression,
            leftParen: .leftParen,
            argumentList: .init(argumentList),
            rightParen: .rightParen
        )
    }
}

