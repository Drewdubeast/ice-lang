//
//  Parser.swift
//  Ice Lang
//
//  Created by Drew Wilken on 5/3/18.
//  Copyright © 2018 Drew Wilken. All rights reserved.
//

import Foundation

enum ParsingError: Error {
    case ExpectedNumber
    case ExpectedIdentifier
    case UnexpectedToken
    case UndefinedOperator(Character)
    
    case ExpectedCharacter(Character)
    case ExpectedOperator
    case ExpectedDeclaration
    case ExpectedExpression
    case ExpectedArgumentList
    case ExpectedFunctionName
}

class Parser {
    
    var tokens: [Token]
    var index = 0
    
    //precedences for different operators
    let precedences: [BinaryOperator : Int] = [.plus : 20,
                                               .minus : 20,
                                               .div : 40,
                                               .mult : 40]
    
    init(for tokens: [Token]) {
        self.tokens = tokens
    }
    
    func peek() -> Token {
        return tokens[index]
    }
    
    func hasNext() -> Bool {
        return index < tokens.count;
    }
    
    func pop() -> Token {
        let ret = tokens[index]
        index+=1
        return ret
    }
    
    func getTokenPrecedence(op: BinaryOperator) throws -> Int {
        guard let precedence = precedences[op] else {
            return -1
        }
        
        return precedence
    }
    
    func parseNumber() throws -> ExpressionNode {
//          Parses a token - expects a number and if it is a number
//          it returns a node for it
        
        guard case let Token.number(num) = pop() else {
            throw ParsingError.ExpectedNumber
        }
        
        return NumberNode(value: num)
    }
    
    func parseIdentifier() throws -> ExpressionNode {
//        Parses a token and returns an identifier node for the
//        string of the identifier
        guard case let Token.identifier(str) = pop() else {
            throw ParsingError.ExpectedIdentifier
        }
        
        return IdentifierNode(name: str)
    }
    
    func parseParens() throws -> ExpressionNode {
//        Affirms that the current expression is inside parenthesis, if not, throws errors.
//        returns an expression node
        guard case Token.leftParen = pop() else {
            throw ParsingError.ExpectedCharacter("(")
        }
        
        let expr = try parseExpression()
        
        guard case Token.rightParen = pop() else {
            throw ParsingError.ExpectedCharacter(")")
        }
        return expr
    }
    
    func parseIdentifierExpression() throws -> ExpressionNode {
        guard case let Token.identifier(name) = pop() else {
            throw ParsingError.ExpectedIdentifier
        }
        
        //check if current identifier is a variable
        //we can assume this if the identifier isn't followed by parens
        guard case Token.leftParen = pop() else {
            return VariableNode(name: name)
        }
        
        var args = [String]()
        
        //if no args, return call node with empty args array
        if case Token.rightParen = peek() {
            return CallNode(name: name, args: [])
        }
        
        while true {
            
            let arg = try parseExpression()
            args.append(arg.description)
            
            if case Token.rightParen = peek() {
                break
            }
            
            guard case Token.comma = peek() else {
                throw ParsingError.ExpectedCharacter(",")
            }
            
            _ = pop() //pop and move to next character
            
        }
        return CallNode(name: name, args: args)
        
    }
    func parseBinaryOperation(lhs: ExpressionNode, exprPrecedence: Int = 0) throws -> ExpressionNode {
        var lhs = lhs
        while true {
            
            guard case let Token.operator(op) = pop() else {
                throw ParsingError.ExpectedOperator
            }
            
            let prec = try getTokenPrecedence(op: op)
            
            if(prec < exprPrecedence) {
                return lhs
            }
        
            var rhs = try parsePrimaryExpression()
            
            if case let Token.operator(op2) = pop() {
                print("popped")
                let nextPrec = try getTokenPrecedence(op: op2)
                
                if(prec < nextPrec) {
                    rhs = try parseBinaryOperation(lhs: rhs)
                }
            }
            
            lhs = BinaryOperationNode(lhs: lhs, rhs: rhs, op: op)
        }
    }
    
    func parsePrimaryExpression() throws -> ExpressionNode {
        //Parses a primary expression which can start in multiple ways
        var node: ExpressionNode
        
        switch(peek()) {
        case .identifier: node = try parseIdentifier()
        case .number: node = try parseNumber()
        case .leftParen: node = try parseParens()
        default: throw ParsingError.ExpectedExpression
        }
        return node
    }
    
    func parseExpression() throws -> ExpressionNode {
        let lhs = try parsePrimaryExpression()
        
        return try parseBinaryOperation(lhs: lhs)
    }
        
    
//     Function -> Prototype Expression
//     Prototype -> Define Identifier ( Arguments )
//     Arguments -> Arguments, Identifier | Identifier | ε
//
//     PrimaryExpression -> Call | Identifier | Number | ( Expression )
//     Call -> Identifier ( Parameters )
//     Parameters -> Parameters, Expression | Expression | ε
//
//     Expression -> Identifier | Number | ( Expression )
//     Expression ->
//     PrimaryExpression Operator Expression | PrimaryExpression
//     PrimaryExpression -> Identifier | Number | ( Expression )
//
//   NOTE: Trying to implement it by myself, not using the tutorial, just by going off of this
}
