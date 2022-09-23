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

    var environment = Environment()

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

    func visit(blockStmt: BlockStmt) -> Void {
        execute(block: blockStmt.statements, enviroment: Environment(parent: environment))
    }

    func visit(ifStmt: IfStmt) -> Void {
        let condition = evaluate(expr: ifStmt.condition)
        if case let .BoolValue(condition) = condition {
            if condition {
                execute(statement: ifStmt.thenBranch)
            } else if let elseBranch = ifStmt.elseBranch {
                execute(statement: elseBranch)
            }
        }
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

    func visit(assignExpr: AssignExpr) -> Value {
        let value = evaluate(expr: assignExpr.value)
        try? environment.assign(name: assignExpr.name, value: value)
        return value
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

    func execute(block statements: [Stmt], enviroment: Environment) {
        let previous = self.environment
        self.environment = enviroment
        for statement in statements {
            execute(statement: statement)
        }
        self.environment = previous
    }
}
