//
//  StmtSyntaxTree.swift
//  LoxCompiler
//
//  Created by Cristian Ilea on 29/08/2022.
//

import Foundation

protocol StmtVisitor {
    associatedtype StmtResult
    func visit(exprStmt: ExpressionStmt) -> StmtResult
    func visit(printStmt: PrintStmt) -> StmtResult
    func visit(varStmt: VarStmt) -> StmtResult
    func visit(blockStmt: BlockStmt) -> StmtResult
    func visit(ifStmt: IfStmt) -> StmtResult
    func visit(whileStmt: WhileStmt) -> StmtResult
}

protocol Stmt {
    func accept<V: StmtVisitor>(visitor: V) -> V.StmtResult
}

struct ExpressionStmt: Stmt {
    let expression: Expr

    func accept<V>(visitor: V) -> V.StmtResult where V : StmtVisitor {
        visitor.visit(exprStmt: self)
    }
}

struct PrintStmt: Stmt {
    let value: Expr

    func accept<V>(visitor: V) -> V.StmtResult where V : StmtVisitor {
        visitor.visit(printStmt: self)
    }
}

struct VarStmt: Stmt {
    let token: Token
    let initializer: Expr

    func accept<V>(visitor: V) -> V.StmtResult where V : StmtVisitor {
        visitor.visit(varStmt: self)
    }
}

struct BlockStmt: Stmt {
    let statements: [Stmt]

    func accept<V>(visitor: V) -> V.StmtResult where V : StmtVisitor {
        visitor.visit(blockStmt: self)
    }
}

struct IfStmt: Stmt {
    let condition: Expr
    let thenBranch: Stmt
    let elseBranch: Stmt?

    func accept<V>(visitor: V) -> V.StmtResult where V : StmtVisitor {
        visitor.visit(ifStmt: self)
    }
}

struct WhileStmt: Stmt {
    let condition: Expr
    let body: Stmt

    func accept<V>(visitor: V) -> V.StmtResult where V : StmtVisitor {
        visitor.visit(whileStmt: self)
    }
}

//struct ForStmt: Stmt {
//
//}
//

//
//struct ReturnStmt: Stmt {
//
//}


