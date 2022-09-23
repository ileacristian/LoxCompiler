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

class Interpreter: ExprVisitor, StmtVisitor {
    typealias ExprResult = Value
    typealias StmtResult = Void

    let environment = Environment()

    func visit(exprStmt: ExpressionStmt) -> Void {
        let _ = evaluate(expr: exprStmt.expression)
    }

    func visit(printStmt: PrintStmt) -> Void {
        let value = evaluate(expr: printStmt.value)
        print(value)
    }


    func visit(varStmt: VarStmt) -> Void {
        let value = evaluate(expr: varStmt.initializer)

        environment.define(name: varStmt.token.lexeme, value: value)
    }

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

    func visit(varExpr: VarExpr) -> Value {
        (try? environment.get(name: varExpr.name)) ?? .NilValue
    }
    
    func evaluate(expr: Expr) -> Value {
        return expr.accept(visitor: self)
    }

    func interpret(statements: [Stmt]) {
        for statement in statements {
            execute(statement: statement)
        }
    }

    func execute(statement: Stmt) {
        statement.accept(visitor: self)
    }
}
