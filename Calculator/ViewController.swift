//
//  ViewController.swift
//  Calculator
//
//  Created by Admin on 27.09.23.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var calcsLabel: UILabel!
    
    @IBOutlet weak var clearButton: UIButton!
    
    @IBOutlet var actionLabels: [UILabel]!
    
    private var newNumTyping = false
    private var hasComma = false
    private var calcsNum = 0.0
    private var stack = CustomStack()
    private var previousOper = ""
    private var selectedOper = selectedOper.none
    private var wasShifted = false
    
    private enum selectedOper {
        case DIVIDE
        case MULTIPLY
        case MINUS
        case PLUS
        case none
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        redrawActionLabels()
    }

    @IBAction func buttonTap(_ sender: UIButton) {
        switch sender.tag {
        case 0, 1, 2, 3, 4, 5, 6, 7, 8, 9:
            clearButton.titleLabel?.text = "C"
            clearButton.titleLabel?.textAlignment = .center
            stack.lastTwo = ["", ""]
            wasShifted = false
            guard !newNumTyping else {
                let num = String(sender.tag)
                makeLabelFromStrNum(fromStr: num)
                newNumTyping = false
                return
            }
            guard (calcsLabel?.text ?? "").filter({ $0 != " " &&  $0 != "," &&  $0 != "-"}).count < 9 else { return }
            let num = (calcsLabel?.text ?? "").replacing(",", with: ".").filter(){ $0 != " "} + String(sender.tag)
            guard !(num == "00" && newNumTyping) else { clearButton.titleLabel?.text = "AC"; return }
            makeLabelFromStrNum(fromStr: num)
        case 10:
            wasShifted = false
            hasComma = false
            clearButton.titleLabel?.text = "C"
            calcsLabel.text = "0"
            calcsNum = 0.0
            stack.lastTwo = ["", ""]
            previousOper = ""
            redrawActionLabels()
        case 11:
            guard !newNumTyping else {
                calcsLabel.text = "-0"
                newNumTyping = false
                return
            }
            guard calcsNum > 0 else {
                guard calcsNum != 0 else {
                    let text = calcsLabel?.text ?? ""
                    guard text.first == "-" else {
                        calcsLabel.text = "-" + text
                        return
                    }
                    calcsLabel.text = String(text.dropFirst())
                    return
                }
                let str = calcsLabel?.text ?? ""
                calcsLabel.text = String(str.dropFirst())
                calcsNum *= -1
                return
            }
            calcsLabel.text = "-" + (calcsLabel?.text ?? "")
            calcsNum *= -1
        case 12:
            guard calcsNum != 0 else {
                calcsLabel.text = "0"
                return
            }
            let num = (calcsLabel?.text ?? "").replacing(",", with: ".").filter(){ $0 != " "}
            calcsNum = Double(num) ?? 0.0
            calcsNum /= 100
            calcsLabel.text = makeLabel(invalidateStrNum(String(calcsNum)).replacing(".", with: ","))
        case 13:
            hasComma = true
            guard let text = calcsLabel.text else { return }
            guard !(text.contains(",") || text.filter({ $0 != " " &&  $0 != "," &&  $0 != "-"}).count == 9) else { return }
            guard !newNumTyping else {
                calcsLabel.text = "0,"
                newNumTyping = false
                return
            }
            calcsLabel.text = text + ","
            clearButton.titleLabel?.text = "C"
            clearButton.titleLabel?.textAlignment = .center
        case 14:
            wasShifted = false
            redrawActionLabels()
            guard stack.lastTwo == ["", ""] else {
                stack.push(String(calcsNum))
                stack.push(stack.lastTwo[0])
                stack.push(stack.lastTwo[1])
                makeLabelFromStrNum(fromStr: stack.calcLastOper())
                newNumTyping = true
                previousOper = ""
                return
            }
            guard stack.top() != "error" else { return }
            hasComma = false
            previousOper = stack.top()
            stack.lastTwo = [stack.top(), String(calcsNum)]
            stack.push(String(calcsNum))
            makeLabelFromStrNum(fromStr: stack.calculate())
            newNumTyping = true
            previousOper = ""
        default:
            break
        }
    }
    
    @objc private func tapActionLabel(_ sender: UITapGestureRecognizer) {
        let tag = sender.view?.tag ?? 19
        for label in actionLabels {
            label.clipsToBounds = true
            label.backgroundColor = UIColor(red: 52 / 255, green: 52 / 255, blue: 52 / 255, alpha: 1.0)
            label.textColor = .systemGreen
        }
        actionLabels[tag - 15].backgroundColor = .systemGreen
        actionLabels[tag - 15].textColor = UIColor(red: 52 / 255, green: 52 / 255, blue: 52 / 255, alpha: 1.0)
        switch tag {
        case 15:
            let flag = (previousOper == "*" || previousOper == "/")
            guard !flag else {
                stack.push(String(calcsNum))
                wasShifted = true
                let res = stack.calcLastOper()
                makeLabelFromStrNum(fromStr: res)
                stack.push(res)
                previousOper = "/"
                stack.push(previousOper)
                newNumTyping = true
                return
            }
            if wasShifted {
                stack.stack.remove(at: 0)
                stack.stack.remove(at: 0)
                stack.push(String(calcsNum))
            }
            stack.push(String(calcsNum))
            stack.push("/")
            newNumTyping = true
            previousOper = "/"
        case 16:
            let flag = (previousOper == "*" || previousOper == "/")
            guard !flag else {
                stack.push(String(calcsNum))
                wasShifted = true
                let res = stack.calcLastOper()
                makeLabelFromStrNum(fromStr: res)
                stack.push(res)
                previousOper = "*"
                stack.push(previousOper)
                newNumTyping = true
                return
            }
            if wasShifted {
                stack.stack.remove(at: 0)
                stack.stack.remove(at: 0)
                stack.push(String(calcsNum))
            }
            stack.push(String(calcsNum))
            stack.push("*")
            newNumTyping = true
            previousOper = "*"
        case 17:
            var flag = (previousOper == "-" || previousOper == "+")
            guard !flag else {
                stack.push(String(calcsNum))
                wasShifted = true
                let res = stack.calcLastOper()
                makeLabelFromStrNum(fromStr: res)
                stack.push(res)
                previousOper = "-"
                stack.push(previousOper)
                newNumTyping = true
                return
            }
            flag = (previousOper == "*" || previousOper == "/")
            guard !flag else {
                guard !wasShifted else {
                    stack.stack.remove(at: 0)
                    stack.stack.remove(at: 0)
                    stack.push(String(calcsNum))
                    stack.push("-")
                    newNumTyping = true
                    previousOper = "-"
                    return
                }
                stack.push(String(calcsNum))
                let res = stack.calculate()
                makeLabelFromStrNum(fromStr: res)
                stack.push(res)
                previousOper = "-"
                stack.push(previousOper)
                newNumTyping = true
                return
            }
            stack.push(String(calcsNum))
            stack.push("-")
            newNumTyping = true
            previousOper = "-"
        case 18:
            var flag = (previousOper == "-" || previousOper == "+")
            guard !flag else {
                stack.push(String(calcsNum))
                wasShifted = true
                let res = stack.calcLastOper()
                makeLabelFromStrNum(fromStr: res)
                stack.push(res)
                previousOper = "+"
                stack.push(previousOper)
                newNumTyping = true
                return
            }
            flag = (previousOper == "*" || previousOper == "/")
            guard !flag else {
                guard !wasShifted else {
                    stack.stack.remove(at: 0)
                    stack.stack.remove(at: 0)
                    stack.push(String(calcsNum))
                    stack.push("+")
                    newNumTyping = true
                    previousOper = "+"
                    return
                }
                stack.push(String(calcsNum))
                let res = stack.calculate()
                makeLabelFromStrNum(fromStr: res)
                stack.push(res)
                previousOper = "+"
                stack.push(previousOper)
                newNumTyping = true
                return
            }
            stack.push(String(calcsNum))
            stack.push("+")
            newNumTyping = true
            previousOper = "+"
        default:
            break
        }
    }
    
    private func setUp() {
        calcsLabel.adjustsFontSizeToFitWidth = true
        redrawActionLabels()
        addGestures()
    }
    
    private func redrawActionLabels() {
        for label in actionLabels {
            label.clipsToBounds = true
            label.layer.cornerRadius = 12
            label.backgroundColor = UIColor(red: 52 / 255, green: 52 / 255, blue: 52 / 255, alpha: 1.0)
            label.textColor = .systemGreen
        }
    }
    
    private func addGestures() {
        for label in actionLabels {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(tapActionLabel))
            label.isUserInteractionEnabled = true
            label.addGestureRecognizer(gesture)
        }
    }
    
    private func redrawActionLabel(withTag tag: Int) {
        redrawActionLabels()
        actionLabels[tag].backgroundColor = .systemOrange
        actionLabels[tag].textColor = .white
    }
    
    private func makeLabelFromStrNum(fromStr num: String) {
        guard !(num == "inf" || num == "-inf") else { calcsLabel.text = "Error"; calcsNum = Double(num) ?? 0.0; return }
        guard !(num == "nan") else { calcsLabel.text = "Не определено"; calcsNum = Double(num) ?? 0.0; return }
        calcsNum = Double(num) ?? 0.0
        guard (calcsNum - round(calcsNum) != 0.0 || hasComma || num.contains("e")) else {
            let index = num.firstIndex(of: ".") ?? num.endIndex
            let result = num[..<index]
            calcsLabel.text = makeLabel(invalidateStrNum(String(Int(result) ?? 0)).replacing(".", with: ","))
            return
        }
        calcsLabel.text = makeLabel(invalidateStrNum(num).replacing(".", with: ","))
    }
    
    private func makeLabel(_ str: String) -> String {
        guard !str.contains("e") else { return str }
        guard str.contains(",") else { return addSpaces(str) }
        let index = str.firstIndex(of: ",")!
        return addSpaces(String(str[..<index])) + String(str[index...])
    }
    
    private func invalidateStrNum(_ s: String) -> String {
        guard s.contains("e") else {
            let countDigits = s.filter(){ $0 != "-" && $0 != "." }.count
            guard countDigits > 9 else { return s }
            guard s.contains(".") else {
                let divisor = pow(10.0, Double(countDigits - 1))
                let roundedPart = roundMeaning(withString: String((Double(s) ?? 0.0) / divisor), withMeaning: 6)
                return (roundedPart == "1.0" ? "1" : roundedPart) + "e" + String(countDigits - 1)
            }
            let startIndex = s.firstIndex(of: ".") ?? s.endIndex
            let beforePoint = s[..<startIndex].count - (s.contains("-") ? 1 : 0)
            return roundMeaning(withString: String(Double(s) ?? 0.0), withMeaning: 9 - beforePoint)
        }
        
        var startIndex = s.index(after: s.firstIndex(of: "e")!)
        let mantis = String(s[startIndex...])
        
        guard !(abs(Int(mantis) ?? -11) < 10) else {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.maximumFractionDigits = 20
            let formattedNum = numberFormatter.string(for: Double(s)) ?? "ERROR"
            guard formattedNum.count < 11 else {
                startIndex = s.startIndex
                let eIndex = s.firstIndex(of: "e") ?? s.endIndex
                let beforeE = String(s[startIndex...s.index(eIndex, offsetBy: -1)])
                let roundedPart = roundMeaning(withString: beforeE, withMeaning: 5)
                return (roundedPart == "1.0" ? "1" : roundedPart) + "e" + mantis
            }
            return formattedNum
        }
        startIndex = s.startIndex
        let eIndex = s.firstIndex(of: "e") ?? s.endIndex
        let beforeE = String(s[startIndex...s.index(eIndex, offsetBy: -1)])
        
        let roundedPart = roundMeaning(withString: beforeE, withMeaning: 5)
        guard roundedPart != "10.0" else {
            return "1" + "e" + String((Int(mantis) ?? 0) + 1)
        }
        return (roundedPart == "1.0" ? "1" : roundedPart) + "e" + mantis
    }
    
    private func addSpaces(_ s: String) -> String {
        var res = s
        guard res.count > 3 else { return res }
        if res.count - 3 < 4 {
            res.insert(" ", at: res.index(res.startIndex, offsetBy: res.count - 3))
        }
        else {
            res.insert(" ", at: res.index(res.startIndex, offsetBy: res.count - 3))
            res.insert(" ", at: res.index(res.startIndex, offsetBy: res.count - 7))
        }
        return res
    }
    
    private func roundMeaning(withString s: String, withMeaning m: Int) -> String {
        let x = Double(s) ?? 0.0
        let y = Double(round(pow(10, Double(m)) * x) / pow(10.0, Double(m)))
        return String(y)
    }
}
