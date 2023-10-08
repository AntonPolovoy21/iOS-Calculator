//
//  CustomStack.swift
//  Calculator
//
//  Created by Admin on 29.09.23.
//

import Foundation

class CustomStack {
    public var stack: [String]
    public var lastTwo = ["", ""]
    
    init() {
        stack = [String]()
    }
    
    public func push(_ value: String) {
        stack.append(value)
    }
    
    public func top() -> String {
        return stack.last ?? "error"
    }
    
    private func pop() -> String {
        let val = stack.last ?? "error"
        stack.removeLast()
        return val
    }
    
    public func count() -> Int {
        stack.count
    }
    
    public func calcLastOper() -> String {
        push(performOperation(Double(pop()) ?? 0.0, pop(), Double(pop()) ?? 0.0))
        return pop()
    }
    
    public func calculate() -> String {
        removeMultiplicative()
        while count() != 1 {
            push(performOperation(Double(pop()) ?? 0.0, pop(), Double(pop()) ?? 0.0))
        }
        return pop()
    }
    
    private func removeMultiplicative() {
        while stack.contains("*") {
            let index = stack.firstIndex(of: "*") ?? -1
            let left = stack[index - 1]
            let right = stack[index + 1]
            stack[index] = performOperation(Double(left)!, "*", Double(right)!)
            stack.remove(at: index - 1)
            stack.remove(at: index)
        }
        while stack.contains("/") {
            let index = stack.firstIndex(of: "/") ?? -1
            let left = stack[index - 1]
            let right = stack[index + 1]
            stack[index] = performOperation(Double(right)!, "/", Double(left)!)
            stack.remove(at: index - 1)
            stack.remove(at: index)
        }
    }
    
    private func performOperation(_ a: Double, _ operation: String, _ b: Double) -> String {
        switch operation {
        case "+":
            return String(a + b)
        case "-":
            return String(b - a)
        case "*":
            return String(a * b)
        case "/":
            return String(b / a)
        default:
            break
        }
        return "hello from switch"
    }
}
