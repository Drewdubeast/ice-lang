//
//  IRGenerator.swift
//  Ice Lang
//
//  Created by Drew Wilken on 5/25/18.
//

import Foundation
import LLVM

class IRGenerator {
    let file: File
    let module: Module
    let builder: IRBuilder
    
    private var parameterValues = [String: IRValue]()
    
    init(with file: File) {
        self.file = file
        module = Module(name: "main")
        builder = IRBuilder(module: module)
    }
    
    func emit() throws {
        for definition in file.definitions {
            _ = try emitDefinition(definition)
        }
        try emitMain()
    }
    
    func emitPrototype(_ prototype: PrototypeNode) -> Function {
        if let function = module.function(named: prototype.name) {
            return function
        }
        
        let args = [IRType](repeating: FloatType.double, count: prototype.args.count)
        let functionType = FunctionType(argTypes: args, returnType: FloatType.double)
        let function = builder.addFunction(prototype.name, type: functionType)

        for(protoArg, var functionArg) in zip(prototype.args, function.parameters) {
            functionArg.name = protoArg.name
        }
        return function
    }
    
    func emitExpr(_ expr: expr) throws -> IRValue {
        switch(expr) {
        case .number(let value): return FloatType.double.constant(value)
        case .call(let name, let args):
            let prototype = file.prototype(name)
            let function = emitPrototype(prototype!)
            let callArgs = try args.map(emitExpr)
            return builder.buildCall(function, args: callArgs)
        case .variable(let name):
            let param = parameterValues[name]
            return param!
        case .binOp(let lhs, let op, let rhs):
            let lhsValue = try emitExpr(lhs)
            let rhsValue = try emitExpr(rhs)
            switch op {
            case .plus: return builder.buildAdd(lhsValue, rhsValue)
            case .minus: return builder.buildSub(lhsValue, rhsValue)
            case .mult: return builder.buildMul(lhsValue, rhsValue)
            case .div: return builder.buildDiv(lhsValue, rhsValue)
            case .mod: return builder.buildRem(lhsValue, rhsValue)
            case .equals:
                let comp = builder.buildFCmp(lhsValue, rhsValue, .orderedEqual)
                return builder.buildIntToFP(comp, type: FloatType.double, signed: false)
            }
        case .ifelse(let cond, let ifBody, let elseBody):
            let condComp = builder.buildFCmp(try emitExpr(cond), FloatType.double.constant(0.0), .orderedNotEqual)
            
            let ifBB = builder.currentFunction!.appendBasicBlock(named: "if")
            let elseBB = builder.currentFunction!.appendBasicBlock(named: "else")
            let mergeBB = builder.currentFunction!.appendBasicBlock(named: "merge")
            
            builder.buildCondBr(condition: condComp, then: ifBB, else: elseBB)
            
            builder.positionAtEnd(of: ifBB)
            let ifValue = try emitExpr(ifBody)
            builder.buildBr(mergeBB)
            
            builder.positionAtEnd(of: elseBB)
            let elseValue = try emitExpr(elseBody)
            builder.buildBr(mergeBB)
            
            builder.positionAtEnd(of: mergeBB)
            
            let phi = builder.buildPhi(FloatType.double)
            phi.addIncoming([(ifValue, ifBB), (elseValue, elseBB)])
            
            return phi
            break
        default:
            return 5 as! IRValue
        }
    }
    
    func emitDefinition(_ definition: FunctionNode) throws -> Function {
        let function = emitPrototype(definition.prototype)
        for (idx, arg) in definition.prototype.args.enumerated() {
            let param = function.parameter(at: idx)!
            parameterValues[arg] = param
        }
        let entryBlock = function.appendBasicBlock(named: "entry")
        builder.positionAtEnd(of: entryBlock)
        let expr = try emitExpr(definition.body)
        builder.buildRet(expr)
        parameterValues.removeAll()
        return function
    }
    
    func emitPrintf() -> Function {
        if let function = module.function(named: "printf") {
            return function
        }
        
        let printfType = FunctionType(argTypes: [PointerType(pointee: IntType.int8)], returnType: IntType.int32, isVarArg: true)
        
        return builder.addFunction("printf", type: printfType)
    }
    
    func emitMain() throws {
        let mainType = FunctionType(argTypes: [], returnType: VoidType())
        let function = builder.addFunction("main", type: mainType)
        
        let entry = function.appendBasicBlock(named: "entry")
        builder.positionAtEnd(of: entry)
        
        let formatString = builder.buildGlobalStringPtr("%f\n")
        let printf = emitPrintf()
        
        for expr in file.expressions {
            let val = try emitExpr(expr)
            _ = builder.buildCall(printf, args: [formatString, val])
        }
        
        builder.buildRetVoid()
    }
}
