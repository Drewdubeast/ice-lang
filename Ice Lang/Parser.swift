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
    
    let operatorPrecendences: [BinaryOperator : Int] = [.plus : 20,
                        .minus : 20,
                        .mult : 40,
                        .div : 40]
    
    func getPrecedence() throws -> Int {
        guard hasNext() else {
            return -1
        }
        
        guard case let Token.operator(op) = peek() else {
            return -1
        }
        
        if case let Token.other(opchar) = peek() {
            throw ParsingError.UndefinedOperator(opchar)
        }
        
        guard let precedence = operatorPrecendences[op] else {
            return 0
        }
        return precedence
    }
    
    func parseNumber() throws -> ExpressionNode {
        guard case let Token.number(value) = pop() else {
            throw ParsingError.ExpectedNumber
        }
        return NumberNode(value: value)
    }
    
    func parseIdentifier() throws -> ExpressionNode {
        guard case let Token.identifier(identifier) = pop() else {
            throw ParsingError.ExpectedIdentifier
        }
        return IdentifierNode(name: identifier)
    }
    
    func parseExpression() throws -> ExpressionNode {
        let node = try parsePrimary()
        return try parseBinaryOpExpression(node: node)
    }
    
    func parseParenthesis() throws -> ExpressionNode {
        guard case Token.leftParen = pop() else {
            throw ParsingError.ExpectedCharacter("(")
        }
        
        let expression = try parseExpression()
        
        guard case Token.rightParen = pop() else {
            throw ParsingError.ExpectedCharacter(")")
        }
        return expression
    }
    
    func parseBinaryOpExpression(node: ExpressionNode, exprPrec: Int = 0) throws -> ExpressionNode {
        var lhs = node
        
        while true {
            let prec = try getPrecedence()
            
            if(prec < exprPrec) {
                return lhs
            }
            
            //check if middle token is an operator
            guard case let Token.operator(op) = pop() else {
                throw ParsingError.ExpectedOperator
            }
            
            var rhs = try parsePrimary()
            
            let nextPrec = try getPrecedence()
            if(prec < nextPrec) {
                rhs = try parseBinaryOpExpression(node: rhs, exprPrec: prec+1)
            }
            
            lhs = BinaryOperationNode(lhs: lhs, rhs: rhs, op: op)
        }
    }
    
    func parsePrototype() throws -> ExpressionNode {
        guard case Token.def = pop() else {
            throw ParsingError.ExpectedExpression
        }
        guard case let Token.identifier(name) = pop() else {
            throw ParsingError.ExpectedIdentifier
        }
        
        let args = try parseParenthesis()
        
        return FunctionPrototypeNode(name: name)
    }
    
    func parsePrimary() throws -> ExpressionNode {
        switch(peek()) {
        case .def:
            return try parsePrototype()
        case .number:
            return try parseNumber()
        case .identifier:
            return try parseIdentifier()
        case .leftParen:
            return try parseParenthesis()
        default:
            throw ParsingError.ExpectedExpression
            
        }
    }
}
