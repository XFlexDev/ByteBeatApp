import Foundation

class BytebeatEvaluator {
    private var tokens: [String] = []
    init(formula: String) {
        self.tokens = parse(formula)
    }
    private func parse(_ formula: String) -> [String] {
        var output: [String] = []
        var stack: [String] = []
        let precedence: [String: Int] = [
            "|": 1, "^": 2, "&": 3,
            "<<": 4, ">>": 4,
            "+": 5, "-": 5,
            "*": 6, "/": 6
        ]
        var tokensList: [String] = []
        let chars = Array(formula.replacingOccurrences(of: " ", with: ""))
        var idx = 0
        while idx < chars.count {
            let ch = chars[idx]
            if ch.isNumber {
                var numStr = ""
                while idx < chars.count && chars[idx].isNumber {
                    numStr.append(chars[idx])
                    idx += 1
                }
                tokensList.append(numStr)
                continue
            } else if ch == "t" {
                tokensList.append("t")
                idx += 1
            } else if ch == "(" || ch == ")" {
                tokensList.append(String(ch))
                idx += 1
            } else if ch == "<" || ch == ">" {
                if idx + 1 < chars.count && chars[idx+1] == ch {
                    tokensList.append(String([ch, ch]))
                    idx += 2
                } else {
                    tokensList.append(String(ch))
                    idx += 1
                }
            } else {
                tokensList.append(String(ch))
                idx += 1
            }
        }
        for c in tokensList {
            if Int(c) != nil {
                output.append(c)
            } else if c == "t" {
                output.append(c)
            } else if c == "(" {
                stack.append(c)
            } else if c == ")" {
                while !stack.isEmpty && stack.last! != "(" {
                    output.append(stack.removeLast())
                }
                if !stack.isEmpty { stack.removeLast() }
            } else if let p1 = precedence[c] {
                while !stack.isEmpty, let p2 = precedence[stack.last!], p2 >= p1 {
                    output.append(stack.removeLast())
                }
                stack.append(c)
            }
        }
        while !stack.isEmpty {
            output.append(stack.removeLast())
        }
        return output
    }
    func evaluate(t: Int) -> Int {
        var stack: [Int] = []
        for token in tokens {
            if token == "t" {
                stack.append(t)
            } else if let val = Int(token) {
                stack.append(val)
            } else {
                if stack.count < 2 { continue }
                let b = stack.removeLast()
                let a = stack.removeLast()
                switch token {
                case "+": stack.append(a &+ b)
                case "-": stack.append(a &- b)
                case "*": stack.append(a &* b)
                case "/": stack.append(b == 0 ? 0 : a / b)
                case "&": stack.append(a & b)
                case "|": stack.append(a | b)
                case "^": stack.append(a ^ b)
                case "<<": stack.append(a << (b & 31))
                case ">>": stack.append(a >> (b & 31))
                default: break
                }
            }
        }
        return stack.last ?? 0
    }
}
