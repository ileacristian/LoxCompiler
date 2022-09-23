//
//  Parser.swift
//  LoxCompiler
//
//  Created by Cristian Ilea on 22/08/2022.
//


//    expression     → equality ;
//    equality       → comparison ( ( "!=" | "==" ) comparison )* ;
//    comparison     → term ( ( ">" | ">=" | "<" | "<=" ) term )* ;
//    term           → factor ( ( "-" | "+" ) factor )* ;
//    factor         → unary ( ( "/" | "*" ) unary )* ;
//    unary          → ( "!" | "-" ) unary
//    | primary ;
//    primary        → NUMBER | STRING | "true" | "false" | "nil"
//    | "(" expression ")" ;


import Foundation

struct ParseError: Error {

}

class Parser {
    var tokens: [Token]
    var current: Int = 0

    init(tokens: [Token]) {
        self.tokens = tokens
    }

    func parse() -> Expr? {
        do {
            return try expression()
        } catch {
            return nil
        }
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
        return try equality()
    }

    func equality() throws -> Expr {
        var expr = try comparison()

        while match(.BANG_EQUAL, .EQUAL_EQUAL) {
            let op = previous()
            let right = try comparison()
            expr = Binary(left: expr, op: op, right: right)
        }

        return expr
    }

    func comparison() throws -> Expr {
        var expr = try term()

        while match(.GREATER, .GREATER_EQUAL, .LESS, .LESS_EQUAL) {
            let op = previous()
            let right = try term()
            expr = Binary(left: expr, op: op, right: right)
        }

        return expr
    }

    func term() throws -> Expr {
        var expr = try factor()

        while match(.MINUS, .PLUS) {
            let op = previous()
            let right = try factor()
            expr = Binary(left: expr, op: op, right: right)
        }

        return expr
    }

    func factor() throws -> Expr {
        var expr = try unary()

        while match(.SLASH, .STAR) {
            let op = previous()
            let right = try unary()
            expr = Binary(left: expr, op: op, right: right)
        }

        return expr
    }

    func unary() throws -> Expr {
        if match(.BANG, .MINUS) {
            let op = previous()
            let right = try unary()
            return Unary(op: op, right: right)
        }

        return try primary()
    }

    func primary() throws -> Expr {
        if match(.FALSE) { return Literal(value: false) }
        if match(.TRUE) { return Literal(value: true) }
        if match(.NIL) { return Literal(value: nil) }

        if match(.NUMBER, .STRING) {
            return Literal(value: previous().literal)
        }

        if match(.LEFT_PAREN) {
            let expr = try expression()
            try consume(.RIGHT_PAREN, messageIfError: "Expect ')' after expression.")
            return Grouping(expression: expr)
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
        return peek().tokenType == tokenType
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
