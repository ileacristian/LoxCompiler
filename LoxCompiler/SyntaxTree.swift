//
//  SyntaxTree.swift
//  LoxCompiler
//
//  Created by Cristian Ilea on 06/08/2022.
//

import Foundation
import SwiftUI

protocol Visitor {
    associatedtype Result
    func visit(binary: Binary) -> Result
    func visit(grouping: Grouping) -> Result
    func visit(literal: Literal) -> Result
    func visit(unary: Unary) -> Result
}

protocol Expr {
    func accept<V: Visitor>(visitor: V) -> V.Result
}

struct Binary: Expr {
    let left: Expr
    let op: Token
    let right: Expr

    func accept<V>(visitor: V) -> V.Result where V : Visitor {
        visitor.visit(binary: self)
    }
}

struct Grouping: Expr {
    let expression: Expr

    func accept<V>(visitor: V) -> V.Result where V : Visitor {
        visitor.visit(grouping: self)
    }
}

struct Literal: Expr {
    let value: Any?

    func accept<V>(visitor: V) -> V.Result where V : Visitor {
        visitor.visit(literal: self)
    }
}

struct Unary: Expr {
    let op: Token
    let right: Expr

    func accept<V>(visitor: V) -> V.Result where V : Visitor {
        visitor.visit(unary: self)
    }
}

struct ASTPrinter: Visitor {
    typealias Result = String
    func print<E: Expr>(_ expr: E) -> String {
        return expr.accept(visitor: self)
    }

    func parenthesize(name: String, _ expressions: Expr...) -> String {
        let result = expressions.map { $0.accept(visitor: self) }.joined(separator: " ")
        return "(\(name) \(result))"
    }

    func visit(binary: Binary) -> String {
        parenthesize(name: binary.op.lexeme, binary.left, binary.right)
    }

    func visit(grouping: Grouping) -> String {
        parenthesize(name: "group", grouping.expression)
    }

    func visit(unary: Unary) -> String {
        parenthesize(name: unary.op.lexeme, unary.right)
    }

    func visit(literal: Literal) -> String {
        guard let value = literal.value else { return "nil" }
        return String(describing: value)
    }
}




func testAST() {
    let expr = Binary(
                        left: Unary(op: Token(tokenType: .MINUS, lexeme: "-", literal: nil, line: 1), right: Literal(value: 123)),
                        op: Token(tokenType: .STAR, lexeme: "*", literal: nil, line: 1),
                        right: Grouping(expression: Literal(value: 45.67))
    )

    print(ASTPrinter().print(expr))
}
