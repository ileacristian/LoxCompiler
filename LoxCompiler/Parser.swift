//
//  Parser.swift
//  LoxCompiler
//
//  Created by Cristian Ilea on 22/08/2022.
//

import Foundation

//        program        → declaration* EOF ;
//
//        declaration    → varDecl
//        | statement ;

//        varDecl        → "var" IDENTIFIER ( "=" expression )? ";" ;

//        statement      → exprStmt
//        | forStmt
//        | ifStmt
//        | printStmt
//        | returnStmt
//        | whileStmt
//        | block ;

//        whileStmt      → "while" "(" expression ")" statement ;

//        ifStmt         → "if" "(" expression ")" statement
//        ( "else" statement )? ;

//        block          → "{" declaration* "}" ;

//        exprStmt       → expression ";" ;
//        printStmt      → "print" expression ";" ;
//        returnStmt     → "return" expression? ";" ;

//        expression     → assignment ;
//        assignment     → IDENTIFIER "=" assignment
//        | logic_or ;

//        logic_or       → logic_and ( "or" logic_and )* ;
//        logic_and      → equality ( "and" equality )* ;

//        equality       → comparison ( ( "!=" | "==" ) comparison )* ;
//        comparison     → term ( ( ">" | ">=" | "<" | "<=" ) term )* ;
//        term           → factor ( ( "-" | "+" ) factor )* ;
//        factor         → unary ( ( "/" | "*" ) unary )* ;

//        unary          → ( "!" | "-" ) unary
//        | primary ;

//        primary        → "true" | "false" | "nil"
//        | NUMBER | STRING
//        | "(" expression ")"
//        | IDENTIFIER ;

struct ParseError: Error {

}

class Parser {
    var tokens: [Token]
    var current: Int = 0

    init(tokens: [Token]) {
        self.tokens = tokens
    }

    func parse() -> [Stmt] {
        var statements: [Stmt] = []
        while !isAtEnd() {
            if let statement = declaration() {
                statements.append(statement)
            }
        }

        return statements
    }

    func declaration() -> Stmt? {
        do {
            if match(.VAR) {
                return try varDeclaration()
            }

            return try statement()
        } catch {
            synchronize()
            return nil
        }
    }

    func statement() throws -> Stmt {
        if match(.IF) {
            return try ifStatement()
        }

        if match(.WHILE) {
            return try whileStatement()
        }

        if match(.PRINT) {
            return try printStatement()
        }

        if match(.LEFT_BRACE) {
            return BlockStmt(statements: try blockStatement())
        }

        return try expressionStatement()
    }

    func ifStatement() throws -> Stmt {
        try consume(.LEFT_PAREN, messageIfError: "Expect '(' after 'if'.")
        let condition = try expression()
        try consume(.RIGHT_PAREN, messageIfError: "Expect ')' after 'if'.")

        let thenBranch = try statement()

        if match(.ELSE) {
            let elseBranch = try statement()
            return IfStmt(condition: condition, thenBranch: thenBranch, elseBranch: elseBranch)
        } else {
            return IfStmt(condition: condition, thenBranch: thenBranch, elseBranch: nil)
        }
    }

    func whileStatement() throws -> Stmt {
        try consume(.LEFT_PAREN, messageIfError: "Expect '(' after 'while'.")
        let condition = try expression()
        try consume(.RIGHT_PAREN, messageIfError: "Expect ')' after 'while'.")

        let bodyStatement = try statement()

        return WhileStmt(condition: condition, body: bodyStatement)
    }

    func blockStatement() throws -> [Stmt] {
        var statements: [Stmt] = []

        while !check(.RIGHT_BRACE) && !isAtEnd() {
            if let declaration = declaration() {
                statements.append(declaration)
            }
        }

        try consume(.RIGHT_BRACE, messageIfError: "Expect } after block.")

        return statements
    }

    func varDeclaration() throws -> Stmt {
        let name = try consume(.IDENTIFIER, messageIfError: "Expect variable name.")

        var initializer: Expr? = nil
        if match(.EQUAL) {
            initializer = try expression()
        }

        try consume(.SEMICOLON, messageIfError: "Expect ';' after variable declaration.")

        if let initializer = initializer {
            return VarStmt(token: name, initializer: initializer)
        } else {
            let err = error(forToken: name, message: "Error while parsing initializer")
            throw err
        }
    }

    func printStatement() throws -> Stmt {
        let value = try expression()
        try consume(.SEMICOLON, messageIfError: "Expect ';' after value.")
        return PrintStmt(value: value)
    }

    func expressionStatement() throws -> Stmt {
        let value = try expression()
        try consume(.SEMICOLON, messageIfError: "Expect ';' after expression.")
        return ExpressionStmt(expression: value)
    }

    func synchronize() {
        advance()
        while !isAtEnd() {
            if previous().tokenType == .SEMICOLON {
                return
            }

            switch peek().tokenType {
                case .CLASS, .FUN, .VAR, .FOR, .IF, .WHILE, .PRINT, .RETURN:
                    return
                default:
                    break
            }

            advance()
        }
    }

    func expression() throws -> Expr {
        return try assignment()
    }

    func assignment() throws -> Expr {
        let expr = try or()

        if match(.EQUAL) {
            let equals = previous()
            let value = try assignment()

            if let expr = expr as? VarExpr {
                let name = expr.name
                return AssignExpr(name: name, value: value)
            }

            let err = error(forToken: equals, message: "Invalid assignment target")
            throw err
        }

        return expr
    }

    func or() throws -> Expr {
        var expr = try and()

        while match(.OR) {
            let op = previous()
            let right = try and()
            expr = LogicalExpr(left: expr, op: op, right: right)
        }

        return expr
    }

    func and() throws -> Expr {
        var expr = try equality()

        while match(.AND) {
            let op = previous()
            let right = try equality()
            expr = LogicalExpr(left: expr, op: op, right: right)
        }

        return expr
    }

    func equality() throws -> Expr {
        var expr = try comparison()

        while match(.BANG_EQUAL, .EQUAL_EQUAL) {
            let op = previous()
            let right = try comparison()
            expr = BinaryExpr(left: expr, op: op, right: right)
        }

        return expr
    }

    func comparison() throws -> Expr {
        var expr = try term()

        while match(.GREATER, .GREATER_EQUAL, .LESS, .LESS_EQUAL) {
            let op = previous()
            let right = try term()
            expr = BinaryExpr(left: expr, op: op, right: right)
        }

        return expr
    }

    func term() throws -> Expr {
        var expr = try factor()

        while match(.MINUS, .PLUS) {
            let op = previous()
            let right = try factor()
            expr = BinaryExpr(left: expr, op: op, right: right)
        }

        return expr
    }

    func factor() throws -> Expr {
        var expr = try unary()

        while match(.SLASH, .STAR) {
            let op = previous()
            let right = try unary()
            expr = BinaryExpr(left: expr, op: op, right: right)
        }

        return expr
    }

    func unary() throws -> Expr {
        if match(.BANG, .MINUS) {
            let op = previous()
            let right = try unary()
            return UnaryExpr(op: op, right: right)
        }

        return try primary()
    }

    func primary() throws -> Expr {
        if match(.FALSE) { return LiteralExpr(value: .BoolValue(false)) }
        if match(.TRUE) { return LiteralExpr(value: .BoolValue(true)) }
        if match(.NIL) { return LiteralExpr(value: .NilValue) }

        if match(.NUMBER(.AnyValue), .STRING(.AnyValue)) {
            switch previous().tokenType {
                case .NUMBER(let value):
                    return LiteralExpr(value: value)
                case .STRING(let value):
                    return LiteralExpr(value: value)
                default:
                    abort()
            }
        }

        if match(.IDENTIFIER) {
            return VarExpr(name: previous())
        }

        if match(.LEFT_PAREN) {
            let expr = try expression()
            try consume(.RIGHT_PAREN, messageIfError: "Expect ')' after expression.")
            return GroupingExpr(expression: expr)
        }

        let error = error(forToken: peek(), message: "Expect expression.")
        throw error
    }

    func match(_ tokenTypes: TokenType...) -> Bool {
        for tokenType in tokenTypes {
            if check(tokenType) {
                advance()
                return true
            }
        }

        return false
    }

    func check(_ tokenType: TokenType) -> Bool {
        if isAtEnd() {
            return false
        }
        return peek().tokenType ~= tokenType
    }

    @discardableResult
    func advance() -> Token {
        if !isAtEnd() {
            current += 1
        }
        return previous()
    }

    @discardableResult
    func consume(_ tokenType: TokenType, messageIfError message: String) throws -> Token {
        if check(tokenType) {
            return advance()
        }

        throw error(forToken: peek(), message: message);
    }

    func error(forToken token: Token, message: String) -> ParseError {
        Lox.shared.error(forToken: token, message: message)
        return ParseError()
    }

    func isAtEnd() -> Bool {
        peek().tokenType == .EOF
    }

    func peek() -> Token {
        tokens[current]
    }

    func previous() -> Token {
        tokens[current - 1]
    }
}
