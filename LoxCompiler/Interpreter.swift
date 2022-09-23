//
//  Interpreter.swift
//  LoxCompiler
//
//  Created by Cristian Ilea on 22/08/2022.
//

import Foundation

struct RuntimeError: Error {
    let token: Token
    let message: String
}

extension Value: Comparable {
    static func +(lhs: Self, rhs: Self) -> Self {
        switch (lhs, rhs) {
            case (.DoubleValue(let num1), .DoubleValue(let num2)):
                return .DoubleValue(num1 + num2)
            case (.StringValue(let str1), .StringValue(let str2)):
                return .StringValue(str1 + str2)
            default:
                return .Error("Cannot apply '+' operator between \(lhs) and \(rhs)")
        }
    }

    static func -(lhs: Self, rhs: Self) -> Self {
        switch (lhs, rhs) {
            case (.DoubleValue(let num1), .DoubleValue(let num2)):
                return .DoubleValue(num1 - num2)
            default:
                return .Error("Cannot apply '-' operator between \(lhs) and \(rhs)")
        }
    }

    static func *(lhs: Self, rhs: Self) -> Self {
        switch (lhs, rhs) {
            case (.DoubleValue(let num1), .DoubleValue(let num2)):
                return .DoubleValue(num1 * num2)
            default:
                return .Error("Cannot apply '*' operator between \(lhs) and \(rhs)")
        }
    }

    static func /(lhs: Self, rhs: Self) -> Self {
        switch (lhs, rhs) {
            case (.DoubleValue(let num1), .DoubleValue(let num2)):
                return .DoubleValue(num1 / num2)
            default:
                return .Error("Cannot apply '/' operator between \(lhs) and \(rhs)")
        }
    }

    static prefix func -(term: Self) -> Self {
        switch (term) {
            case (.DoubleValue(let num)):
                return .DoubleValue(-num)
            default:
                return .Error("Cannot apply unary operator - to \(term)")
        }
    }

    static func < (lhs: Value, rhs: Value) -> Bool {
        switch (lhs, rhs) {
            case (.DoubleValue(let num1), .DoubleValue(let num2)):
                return num1 < num2
            case (.StringValue(let str1), StringValue(let str2)):
                return str1 < str2
            default:
                return false
        }
    }

    var isTruthy: Bool {
        if self != .NilValue {
            return false
        }

        if case let Value.BoolValue(boolean) = self {
            return boolean
        }

        return true
    }
}

class Interpreter: Visitor {
    typealias Result = Value
    
    func visit(binary: BinaryExpr) -> Value {
        let left = evaluate(expr: binary.left)
        let right = evaluate(expr: binary.right)
        
        switch binary.op.tokenType {
            case .MINUS:
                return left - right
            case .PLUS:
                return left + right
            case .STAR:
                return left * right
            case .SLASH:
                return left / right
            case .GREATER:
                return .BoolValue(left > right)
            case .GREATER_EQUAL:
                return .BoolValue(left >= right)
            case .LESS:
                return .BoolValue(left < right)
            case .LESS_EQUAL:
                return .BoolValue(left <= right)
            case .BANG_EQUAL:
                return .BoolValue(left != right)
            case .EQUAL_EQUAL:
                return .BoolValue(left == right)
            default:
                return .Error("Unreachable")
        }
    }
    
    func visit(grouping: GroupingExpr) -> Value {
        evaluate(expr: grouping.expression)
    }
    
    func visit(literal: LiteralExpr) -> Value {
        literal.value
    }
    
    func visit(unary: UnaryExpr) -> Value {
        let expr = evaluate(expr: unary.right)
        
        switch unary.op.tokenType {
            case .MINUS:
                return -expr
            case .BANG:
                return .BoolValue(!expr.isTruthy)
            default:
                return .Error("Unreachable")
        }
    }
    
    func evaluate(expr: Expr) -> Value {
        return expr.accept(visitor: self)
    }
}
