//
//  MAPD714 F22
//  Assignment 3
//  Group 8
//  Member: Suen, Chun Fung (Alan) 301277969
//          Sum, Chi Hung (Samuel) 300858503
//          Wong, Po Lam (Lizolet) 301258847
//  Date:   Oct 23, 2022
//
//  ViewController.swift
//  Strange Calculator - A simple calculator with a strange key layout
//  Version 0.5
//

import Foundation

// *****
// A singleton class to perform calculation logic
// *****
class Calculation {
    static let shared = Calculation()
    private var inputString: String = "0"
    private var result: String = ""
    private var isEndCalcuation = true
    private let maxStepsChar = 15
    private let errorMsgOverflow = "Overflow"
    private let pi = "3.141592654"
    
    private init(){}
    
    // *****
    // Getter to return the calculation result
    // *****
    func getResult() -> String {
        return result
    }

    // *****
    // Getter to return the calculation steps
    // *****
    func getSteps(_ numChar: Int) -> String {
        return String(inputString.suffix(numChar))
    }
    
    // *****
    // Handle numberic, the decmial point, pi and random number input
    // *****
    func handleNumberInput(inNum: String, outChar: Int) -> (String, String) {
        // do nothing if overflow error occurred
        if inputString == errorMsgOverflow {
            return (String(inputString.suffix(outChar)), result)
        }
        // if a calculation has been completed (isEndCalcuation), the input digit will replace the previous steps
        // allow digits input only if the previous char is not a %, )
        if !(inputString.last == "%" || inputString.last == ")") {
            switch inNum {
            case "0":
                //not doing anything if the existing steps contains only a zero
                if inputString != "0" {
                    inputString = (isEndCalcuation) ? "0" : inputString.appending(inNum)
                }
                evaluateAnswer()
            case "1", "2", "3", "4", "5", "6", "7", "8", "9":
                inputString = (inputString == "0" || isEndCalcuation) ? inNum : inputString.appending(inNum)
                evaluateAnswer()
            case ".":
                // allow a period input only if the previous char is a number
                if inputString.last == "1" || inputString.last == "2" || inputString.last == "3" || inputString.last == "4" || inputString.last == "5" || inputString.last == "6" || inputString.last == "7" || inputString.last == "8" || inputString.last == "9" || inputString.last == "0" {
                    // allow a period input onces per operand
                    if !hasDecmial() {
                        inputString = inputString.appending(inNum)
                    }
                }
            case "π":
                //allow a pi constant only if this is the start of the next operand
                if inputString == "0" || inputString.last == "+" || inputString.last == "-" || inputString.last == "x" || inputString.last == "÷" {
                    inputString = (inputString == "0" || isEndCalcuation) ? pi : inputString.appending(pi)
                    evaluateAnswer()
                }
            case "ran":
                //allow a random number only if this is the start of the next operand
                if inputString == "0" || inputString.last == "+" || inputString.last == "-" || inputString.last == "x" || inputString.last == "÷" {
                    let rand = String(Float.random(in: 0 ..< 1))
                    inputString = (inputString == "0" || isEndCalcuation) ? rand : inputString.appending(rand)
                    evaluateAnswer()
                }
            default:
                print ("func saveNumInput: \(inNum) not handled")
            }
        }
        isEndCalcuation = false
        
        return (String(inputString.suffix(outChar)), result)
    }

    // *****
    // Handle special keys input - AC (all clear) and the back (delete) key
    // *****
    func handleSpecialKeys(inKey: String, outChar: Int) -> (String, String) {
        switch inKey {
        case "AC":
            // clear all pressed
            inputString = "0"
            result = ""
            isEndCalcuation = true
        case "←":
             // back key pressed
            // do nothing if overflow error occurred
            if inputString == errorMsgOverflow {
                return (String(inputString.suffix(outChar)), result)
            }
            //remove the square sign from the last operand (if any)
            if !removeSquare() {
                //remove sin/cos/tan keyword from the last operand (if any)
                if !removeSinCosTan() {
                    //remove the square root sign from the last operand (if any)
                    if !removeSquareRoot() {
                        if inputString.last == ")" {
                            //handle deletion of a -ve value
                            makeLastOperandPositive()
                        } else {
                            // just remove the last character
                            inputString = String(inputString.dropLast())
                        }
                    }
                }
            }
            if inputString.isEmpty {
                inputString = "0"
                isEndCalcuation = true
            }
            evaluateAnswer()
        default:
            print ("func handleSpecialKeys: \(inKey) not handled")
        }
        return (String(inputString.suffix(outChar)), result)
    }
    
    // *****
    // Handle operator keys "+", "-", "x", "÷" , "=", "+/-", "%"
    // *****
    func handleOperaters(inKey: String, outChar: Int) -> (String, String) {
        // do nothing if overflow error occurred
        if inputString == errorMsgOverflow {
            return (String(inputString.suffix(outChar)), result)
        }

        switch inKey {
        case "+", "-", "x", "÷":
            if inputString.last == "+" || inputString.last == "-" || inputString.last == "x" || inputString.last == "÷" || inputString.last == "." {
                inputString = String(inputString.dropLast())
            }
            inputString = inputString.appending(inKey)
            isEndCalcuation = false
        case "%":
            // allow a percentage input only if the previous char is a number
            if inputString.last == "1" || inputString.last == "2" || inputString.last == "3" || inputString.last == "4" || inputString.last == "5" || inputString.last == "6" || inputString.last == "7" || inputString.last == "8" || inputString.last == "9" || inputString.last == "0" {
                inputString = inputString.appending(inKey)
            }
            isEndCalcuation = false
            evaluateAnswer()
        case "+/-":
            if hasOneOperandOnly() {
                if inputString.first == "-" {
                    // remove leading -ve sign coming from the previous calculation
                    inputString = String(inputString.dropFirst())
                } else {
                    // make the operand -ve
                    makeLastOperandNegative()
                }
            } else {
                // add a pair of () to wrap the number as -ve
                // allow to make -ve only if the previous char is a number or %
                let lastOperand = getLastOperand()
                if inputString.last == "1" || inputString.last == "2" || inputString.last == "3" || inputString.last == "4" || inputString.last == "5" || inputString.last == "6" || inputString.last == "7" || inputString.last == "8" || inputString.last == "9" || inputString.last == "0" || inputString.last == "%" {
                    makeLastOperandNegative()
                } else if lastOperand.prefix(2) == "(-" {
                    // switch the -ve value to +ve
                    makeLastOperandPositive()
                }
            }
            isEndCalcuation = false
            evaluateAnswer()
        case "sin", "cos", "tan":
            if !(inputString.last == "+" || inputString.last == "-" || inputString.last == "x" || inputString.last == "÷" || inputString.last == "." ) {
                toggleSinCosTan(inKey)
                isEndCalcuation = false
                evaluateAnswer()
            }
        case "x²":
            if !(inputString.last == "+" || inputString.last == "-" || inputString.last == "x" || inputString.last == "÷" || inputString.last == "." ) {
                toggleSquare()
                isEndCalcuation = false
                evaluateAnswer()
            }
        case "√x":
            if !(inputString.last == "+" || inputString.last == "-" || inputString.last == "x" || inputString.last == "÷" || inputString.last == "." ) {
                toggleSquareRoot()
                isEndCalcuation = false
                evaluateAnswer()
            }
        case "=":
            // if the input not yet completed, do nothing
            if !(inputString.last == "+" || inputString.last == "-" || inputString.last == "x" || inputString.last == "÷" || inputString.last == "." || isEndCalcuation) {
                //clear the steps and replace it with the final answer
                evaluateAnswer()
                isEndCalcuation = true
                inputString = result
                result = ""
            }
        default:
            print ("func handleOperaters: \(inKey) not handled")
        }
        return (String(inputString.suffix(outChar)), result)
    }

    // *****
    // Check whether the whole input has only 1 operand so far
    // *****
    private func hasOneOperandOnly() -> Bool {
        var found: Bool = false
        found = inputString.contains("+") || inputString.contains("x") || inputString.contains("÷") || inputString.contains("sin") || inputString.contains("cos") || inputString.contains("tan") || inputString.contains("²") || inputString.contains("√")
        if (!found) {
            found = inputString.contains("-") && inputString.first != "-"
        }
        return !found
    }
    
    // *****
    // Check whether the last input operand has a decmial point
    // *****
    private func hasDecmial() -> Bool {
        var found: Bool = false
        for ch in inputString.reversed() {
            if ch == "+" || ch == "-" || ch == "x" || ch == "÷" {
                break
            }
            if ch == "." {
                found = true
            }
        }
        return found
    }
    
    // *****
    // Make the last input operand be a -ve value
    // *****
    private func makeLastOperandNegative() {
        var extractedString = ""
        var charCount = 0
        // search the inputString backward for a operand and save to a temp var
        for ch in inputString.reversed() {
            if (ch.isASCII && ch.isNumber) || ch == "." || ch == "%" {
                extractedString.append(ch)
                charCount += 1
            } else if ch == "+" || ch == "-" || ch == "x" || ch == "÷" {
                break
            }
        }
        extractedString = String(extractedString.reversed())
        print("func makeLastOperandNegative: extractedString is \(extractedString)")
        
        // drop the last operand from the original inputString and append the -ve value
        inputString = String(inputString.dropLast(charCount)).appending("(-").appending(extractedString).appending(")")
        print("func makeLastOperandNegative: new inputString is \(inputString)")
    }
    
    // *****
    // Make the last input operand be a +ve value
    // *****
    private func makeLastOperandPositive() {
        var extractedString = ""
        var charCount = 0
        // search the inputString backward for a operand in () and save to a temp var
        for ch in inputString.reversed() {
            if (ch.isASCII && ch.isNumber) || ch == "." || ch == "%" {
                extractedString.append(ch)
                charCount += 1
            } else if ch == "+" || ch == "-" || ch == "x" || ch == "÷" {
                break
            }
        }
        charCount += 3  //add 3 more characters (, -, ) to the counter
        extractedString = String(extractedString.reversed())
        print("func makeLastOperandNegative: extractedString is \(extractedString)")
        
        // drop the last operand from the original inputString and append the +ve value
        inputString = String(inputString.dropLast(charCount)).appending(extractedString)
        print("func makeLastOperandNegative: new inputString is \(inputString)")
    }
    
    // *****
    // Toggle the sin, cos, tan keywords in the input string
    // *****
    private func toggleSinCosTan(_ keyword: String) {
        var extractedString = getLastOperand()
        let charCount = extractedString.count
        print("func toggleSinCosTan: extractedString is \(extractedString)")
        
        if extractedString.prefix(3) == keyword {
            //remove the sin/cos/tan if the same key is hit again
            extractedString = String(extractedString.dropFirst(4).dropLast())
        } else {
            if extractedString.prefix(3) == "sin" || extractedString.prefix(3) == "cos" || extractedString.prefix(3) == "tan" {
                // replace any existing sin/cos/tan with the latest input
                extractedString = String(extractedString.dropFirst(3))
                extractedString = keyword.appending(extractedString)
            } else {
                // add sin/cos/tan at the beginning
                extractedString = keyword.appending("(").appending(extractedString).appending(")")
            }
        }
        // drop the last operand from the original inputString and append the sin/cos/tan with brackets
        inputString = String(inputString.dropLast(charCount).appending(extractedString))
        print("func toggleSinCosTan: new inputString is \(inputString)")
    }
    
    // *****
    // Remove the sin, cos, tan keywords from the input string if found only in the last operand
    // *****
    private func removeSinCosTan() -> Bool {
        var extractedString = getLastOperand()
        let charCount = extractedString.count
        print("func removeSinCosTan: extractedString is \(extractedString)")
        
        if extractedString.prefix(3) == "sin" || extractedString.prefix(3) == "cos" || extractedString.prefix(3) == "tan" {
            extractedString = String(extractedString.dropFirst(4).dropLast())
            inputString = inputString.dropLast(charCount).appending(extractedString)
            print("func removeSinCosTan: inputString is \(inputString)")
            return true
        } else {
            return false
        }
    }
        
    // *****
    // Toggle the square operator in the input string
    // *****
    private func toggleSquare() {
        let lastOperand = getLastOperand()
        if inputString.last == "²" {
            if lastOperand.contains("sin") || lastOperand.contains("cos") || lastOperand.contains("tan") || lastOperand.contains("√") {
                // remove the leading ( and trailing )²
                inputString = String(inputString.dropFirst().dropLast(2))
            } else {
                inputString = String(inputString.dropLast())
            }
        } else {
            if lastOperand.contains("sin") || lastOperand.contains("cos") || lastOperand.contains("tan") || lastOperand.contains("√") {
                // add the leading ( and trailing )²
                inputString = "(".appending(inputString.appending(")²"))
            } else {
                inputString = inputString.appending("²")
            }
        }
    }

    // *****
    // Remove the square sign in the input string
    // *****
    private func removeSquare() -> Bool {
        let lastOperand = getLastOperand()
        if inputString.last == "²" {
            if lastOperand.contains("sin") || lastOperand.contains("cos") || lastOperand.contains("tan") || lastOperand.contains("√") {
                // remove the leading ( and trailing )²
                inputString = String(inputString.dropFirst().dropLast(2))
            } else {
                inputString = String(inputString.dropLast())
            }
            return true
        } else {
            return false
        }
    }
    
    // *****
    // Toggle the square root operator in the input string
    // *****
    private func toggleSquareRoot() {
        var extractedString = getLastOperand()
        let charCount = extractedString.count
        print("func toggleSquareRoot: extractedString is \(extractedString)")
        
        if extractedString.prefix(1) == "√" {
            //remove the √ sign if the same key is hit again
            extractedString = String(extractedString.dropFirst(2).dropLast())
        } else {
            // add the √ sign at the beginning
            extractedString = ("√(").appending(extractedString).appending(")")
        }
        // drop the last operand from the original inputString and append the sin/cos/tan with brackets
        inputString = String(inputString.dropLast(charCount).appending(extractedString))
        print("func toggleSquareRoot: new inputString is \(inputString)")
    }
    
    // *****
    // Remove the square root operator in the input string
    // *****
    private func removeSquareRoot() -> Bool {
        var extractedString = getLastOperand()
        let charCount = extractedString.count
        print("func removeSquareRoot: extractedString is \(extractedString)")
        
        if extractedString.prefix(1) == "√" {
            extractedString = String(extractedString.dropFirst(2).dropLast())
            inputString = inputString.dropLast(charCount).appending(extractedString)
            print("func removeSquareRoot: inputString is \(inputString)")
            return true
        } else {
            return false
        }
    }
    
    // *****
    // Extract the last operand from the input string
    // *****
    private func getLastOperand() -> String {
        var extractedString = ""
        var charCount = 0
        var bracketFound = false
        // search the inputString backward for a operand and save to a temp var
        for ch in inputString.reversed() {
            //the following () checking is used to handle -ve values
            if ch == ")" {
                bracketFound = true
            }
            if ch == "(" {
                bracketFound = false
            }
            if ch == "+" || (ch == "-" && !bracketFound) || ch == "x" || ch == "÷" {
                break
            } else {
                extractedString.append(ch)
                charCount += 1
            }
        }
        extractedString = String(extractedString.reversed())
        print("func getLastOperand: last operand is \(extractedString)")
        return extractedString
    }
    
    // *****
    // Calculate the result of the input steps from left to right and follow operator precedence
    // *****
    private func evaluateAnswer() {
        // play safe to discard calls if the inputString is incomplete
        let char = inputString.last
        if char == "+" || char == "-" || char == "x" || char == "÷" || char == "."  {
            return
        }
        // tokenize the input string from left to right
        var tokens: [String] = tokenizeInputString()
        
        // evaulate operations with 1 operand only
        tokens = expandTokens(tokens)
        print("func evaluateAnswer: tokens array is \(tokens)")

        // evaluate the tokens from left to right and only handle x, ÷
        // by repeating the loop from the beginning after a pair of operands is calculated
        var counter = 1
        while counter < tokens.count  {
            var foundOperator = false
            while counter < tokens.count{
                switch tokens[counter] {
                case "x":   // multiply
                    let answer: Double = (Double(tokens[counter - 1]) ?? 0.0) * (Double(tokens[counter + 1]) ?? 0.0)
                    tokens = replaceTokens(originalTokens: tokens, newToken: String(format: "%.10f", answer), index: counter)
                    foundOperator = true
                case "÷":   // divide
                    let answer: Double = (Double(tokens[counter - 1]) ?? 0.0) / (Double(tokens[counter + 1]) ?? 0.0)
                    tokens = replaceTokens(originalTokens: tokens, newToken: String(format: "%.10f", answer), index: counter)
                    foundOperator = true
                default:    // do nothing
                    break
                }
                counter += 1
                print("func evaluateAnswer: New tokens array is \(tokens)")
                break
            }
            if foundOperator == true {      // at least did 1 calculation, loop again all tokens
                counter = 1
            }
        }

        // evaluate the tokens from left to right and only handle +, -
        // by repeating the loop from the beginning after a pair of operands is calculated
        counter = 1
        while counter < tokens.count  {
            var foundOperator = false
            while counter < tokens.count{
                switch tokens[counter] {
                case "+":   // add
                    let answer: Double = (Double(tokens[counter - 1]) ?? 0.0) + (Double(tokens[counter + 1]) ?? 0.0)
                    tokens = replaceTokens(originalTokens: tokens, newToken: String(format: "%.10f", answer), index: counter)
                    foundOperator = true
                case "-":   // subract
                    let answer: Double = (Double(tokens[counter - 1]) ?? 0.0) - (Double(tokens[counter + 1]) ?? 0.0)
                    tokens = replaceTokens(originalTokens: tokens, newToken: String(format: "%.10f", answer), index: counter)
                    foundOperator = true
                default:    // do nothing
                    break
                }
                counter += 1
                print("func evaluateAnswer: New tokens array is \(tokens)")
                break
            }
            if foundOperator == true {      // at least did 1 calculation, loop again all tokens
                counter = 1
            }
        }
        //update result label only if the final value is numeric
        updateResult(tokens)
    }
    
    // *****
    // Convert the input string into an array of operands and operators
    // *****
    private func tokenizeInputString() -> [String] {
        var workingTokens = [String]()
        var extractedString = ""
        var isHandlingbrackets = false
        
        for ch in inputString {
            if ch == "(" {
                // handle all char in the ()
                isHandlingbrackets = true
                extractedString.append(ch)
            } else if ch == ")" {
                // finished all char in ()
                isHandlingbrackets = false
                extractedString.append(ch)
            } else if isHandlingbrackets || (ch != "+" && ch != "-" && ch != "x" && ch != "÷") {
                extractedString.append(ch)
            } else {
                // found an operator. now to save the working operand
                workingTokens.append(extractedString)
                extractedString = ""
                workingTokens.append(String(ch))
            }
        }
        // handle the last operand
        if !extractedString.isEmpty {
            workingTokens.append(extractedString)
        }

        return workingTokens
    }
    
    // *****
    // Evaulate operators within a token
    // *****
    private func expandTokens(_ intokens: [String]) -> [String] {
        var result = intokens
        
        var idx = 0
        for var aToken in intokens {
            print("func expandTokens: aToken_a is \(aToken)")
            // transform the percentage values into decmials
            if aToken.contains("%") {
                let value = aToken.filter("0123456789.".contains)
                let newValue = String(format: "%.10f", (Double(value) ?? 0)  / 100.0)
                let oldValue = value.appending("%")
                let aNewToken = aToken.replacingOccurrences(of: oldValue, with: newValue, options: .literal, range: nil)
                result[idx] = aNewToken
                aToken = aNewToken
                print("func expandTokens: aToken_b is \(aToken)")
            }
            //handle brackets from inside out of a token
            var bracketsFound: Bool = true
            while (bracketsFound) {
                bracketsFound = false
                var startBracketIndex = -1
                var endBracketIndex = -1
                for (index, ch) in aToken.reversed().enumerated() {
                    if ch == "(" {
                        startBracketIndex = aToken.count - index - 1    //convert to count forward index
                        bracketsFound = true
                        break
                    }
                }
                for (index, ch) in aToken.enumerated() {
                    if ch == ")" {
                        endBracketIndex = index
                        bracketsFound = true
                        break
                    }
                }
                if startBracketIndex >= 0 && endBracketIndex >= 0 {
                    print("func expandTokens: startBracketIndex is \(startBracketIndex)")
                    print("func expandTokens: endBracketIndex is \(endBracketIndex)")
                    let range = aToken.index(aToken.startIndex, offsetBy: startBracketIndex + 1)...aToken.index(aToken.startIndex, offsetBy: endBracketIndex - 1)
                    let innerToken = String(aToken[range])
                    let oldInnerToken = ("(").appending(innerToken.appending(")"))
                    let newInnerToken = evaluateSingleOperator(innerToken)
                    aToken = aToken.replacingOccurrences(of: oldInnerToken, with: newInnerToken, options: .literal, range: nil)
                    result[idx] = aToken
                }
                print("func expandTokens: aToken_b is \(aToken)")
            }
            aToken = evaluateSingleOperator(aToken)
            result[idx] = aToken
            idx += 1
        }
        return result
    }
    
    private func evaluateSingleOperator(_ workingToken: String) -> String {
        var newValue: String = workingToken
        if workingToken.contains("²") {
            let value = workingToken.filter("0123456789.-".contains)
            newValue = String(format: "%.10f", pow((Double(value) ?? 0), 2))
        }
        if workingToken.contains("√") {
            let value = workingToken.filter("0123456789.-".contains)
            newValue = String(format: "%.10f", sqrt((Double(value) ?? 0)))
        }
        if workingToken.prefix(3) == "sin" {
            var value: Double = Double(String(workingToken.dropFirst(3))) ?? 0.0
            value = sin(value * Double.pi / 180)
            newValue = String(format: "%.10f", value)
        }
        if workingToken.prefix(3) == "cos" {
            var value: Double = Double(String(workingToken.dropFirst(3))) ?? 0.0
            value = cos(value * Double.pi / 180)
            newValue = String(format: "%.10f", value)
        }
        if workingToken.prefix(3) == "tan" {
            var value: Double = Double(String(workingToken.dropFirst(3))) ?? 0.0
            value = tan(value * Double.pi / 180)
            newValue = String(format: "%.10f", value)
        }

        print("func evaluateSingleOperator: workingToken is \(newValue)")
        return newValue
    }

    // *****
    // Replace a set of operands / operator with its evaluated result
    // *****
    private func replaceTokens(originalTokens: [String], newToken: String, index: Int) -> [String] {
        // remove a pair of operands an their operator. Than add back the result into the original position
        var newTokens = originalTokens
        newTokens.remove(at: index - 1)
        newTokens.remove(at: index - 1)
        newTokens.remove(at: index - 1)
        newTokens.insert(newToken, at: index - 1)
        
        return newTokens
    }
    
    // *****
    // Update and format the result label content with evaluated result
    // *****
    private func updateResult(_ inTokens: [String]) {
        //update the result label only if it is an valid evaluation
        if inTokens.count == 1 {
            if let number = Double(inTokens[0]) {
                // the result is an integer, remove the trailing zero
                let RoundedNumber = Double(String(format: "%.f", number))
                if RoundedNumber == number {
                    result = String(format: "%.f", number)
                } else {
                    result = String(number)
                }
            }
        }
        //check the display overflow may occur
        if result.count > maxStepsChar {
            if result.contains(".") {
                // try to trim the decmial places to prevent overflow if possible
                var workingString = result
                while workingString.contains(".") && workingString.count > maxStepsChar {
                    workingString = String(workingString.dropLast())
                }
                if workingString.contains(".") {
                    // trim success
                    result = workingString
                } else {
                    result = errorMsgOverflow
                }
            } else {
                result = errorMsgOverflow
            }
        }
        if result == inputString {
            result = ""
        }
    }
}
