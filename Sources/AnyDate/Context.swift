/*
 The MIT License (MIT)
 
 Original Copyright (c) 2015-2017 Aaron Raddon
 Swift port Copyright (c) 2019 Hèctor Marquès Ranea
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

import Foundation

struct Context {
    let preferMonthFirst: Bool
    
    private(set) var skipped: Int
    private(set) var trimmed: Int

    var twelveHourFormat: Bool = false
    var ambiguousMD:      Bool = false
    var stateDate:        DateState
    var stateTime:        TimeState
    var format:           [Character]
    var datestr:          String
    var fullMonth:        String = ""
    var skip:             Int = 0
    var extra:            Int = 0
    
    var part1Len:         Int = 0
    
    var yeari:            Int = 0
    var yearlen:          Int = 0
    
    var moi:              Int = 0
    var molen:            Int = 0
    
    var dayi:             Int = 0
    var daylen:           Int = 0
    
    var houri:            Int = 0
    var hourlen:          Int = 0
    
    var mini:             Int = 0
    var minlen:           Int = 0
    
    var seci:             Int = 0
    var seclen:           Int = 0
    
    var msi:              Int = 0
    var mslen:            Int = 0
    
    var offseti:          Int = 0
    
    var tzi:              Int = 0
    var tzlen:            Int = 0
    
    var t:                Date?
    
    private init(skipped: Int,
                     trimmed: Int,
                     stateDate: DateState,
                     stateTime: TimeState,
                     datestr: String,
                     preferMonthFirst: Bool,
                     format: [Character]) {
        self.skipped = skipped
        self.trimmed = trimmed
        
        self.stateDate = stateDate
        self.stateTime = stateTime
        self.datestr = datestr
        self.preferMonthFirst = preferMonthFirst
        self.format = format
    }

    init(dateStr: String, timeZone: TimeZone?, preferMonthFirst: Bool, skipped: Int, trimmed: Int) {
        self.init(skipped: skipped,
                  trimmed: trimmed,
                  stateDate: .dateStart,
                  stateTime: .timeIgnore,
                  datestr: dateStr,
                  preferMonthFirst: preferMonthFirst,
                  format: Array(dateStr))
    }
}

extension Context {
    func nextIs(i: Int, b: Character) -> Bool {
        if datestr.count > i+1 && Array(datestr)[i+1] == b {
            return true
        }
        return false
    }
    
    mutating func set(start: Int, value: String) {
        guard start >= 0 else { return }
        guard format.count >= start+value.count else { return }
        for (index, character) in Array(value).enumerated() {
            format[start+index] = character
        }
    }
    
    mutating func set(start: Int, value: String, length: Int) {
        guard start >= 0 else { return }
        guard format.count >= start+value.count else { return }
        if value.count < length {
            for i in (start + value.count) ..< (start + length) {
                format.remove(at: i)
            }
        } else if value.count > length {
            for i in (start + value.count) ... (start + value.count + length) {
                format.insert(" ", at: i)
            }
        }
        for (index, character) in Array(value).enumerated() {
            format[start+index] = character
        }
    }

    mutating func setMonth() {
        if molen == 2 {
            set(start: moi, value: "01")
        } else if molen == 1 {
            set(start: moi, value: "1")
        }
    }
    
    mutating func setDay() {
        if daylen == 2 {
            set(start: dayi, value: "02")
        } else if daylen == 1 {
            set(start: dayi, value: "2")
        }
    }
    
    mutating func setYear() {
        if yearlen == 2 {
            set(start: yeari, value: "06")
        } else if yearlen == 4 {
            set(start: yeari, value: "2006")
        }
    }
    
    mutating func coalesceDate(end: Int) {
        if yeari > 0 {
            if yearlen == 0 {
                yearlen = end - yeari
            }
            setYear()
        }
        if moi > 0 && molen == 0 {
            molen = end - moi
            setMonth()
        }
        if dayi > 0 && daylen == 0 {
            daylen = end - dayi
            setDay()
        }
    }
    
    #if VERBOSE
    func ts() -> String {
        return "h:(\(houri):\(hourlen) m:(\(mini):\(minlen)) s:(\(seci):\(seclen))"
    }
    
    func ds() -> String {
        return "\(datestr) d:(\(dayi):\(daylen)) m:(\(moi):\(molen)) y:(\(yeari):\(yearlen))"
    }
    #endif
    
    mutating func coalesceTime(end: Int) {
        // 03:04:05
        // 15:04:05
        // 3:04:05
        // 3:4:5
        // 15:04:05.00
        if houri > 0 {
            if hourlen == 2 {
                if twelveHourFormat {
                    set(start: houri, value: "03")
                } else {
                    set(start: houri, value: "15")
                }
                
            } else if hourlen == 1 {
                self.twelveHourFormat = true
                set(start: houri, value: "3")
            }
        }
        if mini > 0 {
            if minlen == 0 {
                minlen = end - mini
            }
            if minlen == 2 {
                set(start: mini, value: "04")
            } else {
                set(start: mini, value: "4")
            }
        }
        if seci > 0 {
            if seclen == 0 {
                seclen = end - seci
            }
            if seclen == 2 {
                set(start: seci, value: "05")
            } else {
                set(start: seci, value: "5")
            }
        }
        if msi > 0 {
            for i in 0 ..< mslen {
                format[msi+i] = "0"
            }
        }
    }
    
    mutating func setFullMonth(month: String) {
        if moi == 0 {
            format = Array("\("January")\(String(format.dropFirst(month.count)))")
        }
    }
    
    mutating func trimExtra() {
        if extra > 0 && format.count > extra {
            trimmed += datestr.count - extra
            format = Array(format.prefix(extra))
            datestr = String(datestr.prefix(extra))
            extra = 0
        }
    }
    
    mutating func complete() {
        if !fullMonth.isEmpty {
            setFullMonth(month: fullMonth)
            fullMonth = ""
        }
        
        if skip > 0 && self.format.count > skip {
            self.format = Array(self.format.dropFirst(skip))
            self.datestr = String(self.datestr.dropFirst(skip))
            skipped += skip
            skip = 0
        }
    }
}
