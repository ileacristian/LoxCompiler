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
    func visit(binary: BinaryExpr) -> Result
    func visit(grouping: GroupingExpr) -> Result
    func visit(literal: LiteralExpr) -> Result
    func visit(unary: UnaryExpr) -> Result
}

protocol Expr {
    func accept<V: Visitor>(visitor: V) -> V.Result
}

struct BinaryExpr: Expr {
    let left: Expr
    let op: Token
    let right: Expr

    func accept<V>(visitor: V) -> V.Result where V : Visitor {
        visitor.visit(binary: self)
    }
}

struct GroupingExpr: Expr {
    let expression: Expr

    func accept<V>(visitor: V) -> V.Result where V : Visitor {
        visitor.visit(grouping: self)
    }
}

struct LiteralExpr: Expr {
    let value: Value

    func accept<V>(visitor: V) -> V.Result where V : Visitor {
        visitor.visit(literal: self)
    }
}

struct UnaryExpr: Expr {
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

    func visit(binary: BinaryExpr) -> String {
        parenthesize(name: binary.op.lexeme, binary.left, binary.right)
    }

    func visit(grouping: GroupingExpr) -> String {
        parenthesize(name: "group", grouping.expression)
    }

    func visit(unary: UnaryExpr) -> String {
        parenthesize(name: unary.op.lexeme, unary.right)
    }

    func visit(literal: LiteralExpr) -> String {
        switch literal.value {
            case .StringValue(let str):
                return str
            case .DoubleValue(let number):
                return String(describing: number)
            case .AnyValue:
                abort()
            case .BoolValue(let boolean):
                return String(describing: boolean)
            case .NilValue:
                return "nil"
            case .Error(_):
                return "Error"
        }
    }
}

func testAST() {
    let expr = BinaryExpr(
        left: UnaryExpr(op: Token(tokenType: .MINUS, lexeme: "-", line: 1), right: LiteralExpr(value: .DoubleValue(123))),
                        op: Token(tokenType: .STAR, lexeme: "*", line: 1),
        right: GroupingExpr(expression: LiteralExpr(value: .DoubleValue(45.3)))
    )

    print(ASTPrinter().print(expr))
    print(Interpreter().evaluate(expr: expr))
}
