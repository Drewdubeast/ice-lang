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
    
    func parsePrimaryExpression() throws -> ExpressionNode {
        //Parses a primary expression which can start in multiple ways
        var node: ExpressionNode
        
        switch(peek()) {
        case .identifier: node = try parseIdentifier()
        case .number: node = try parseNumber()
        default:
            throw ParsingError.ExpectedExpression
        }
        return node
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
