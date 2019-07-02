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
import Idioms

func parseAny(dateString: String,
              timeZone: TimeZone?,
              locale: Locale?,
              preferMonthFirst: Bool) throws -> Context {
    var context = try parse(dateString: dateString,
                            timeZone: timeZone,
                            locale: locale,
                            preferMonthFirst: preferMonthFirst,
                            skipped: 0,
                            trimmed: 0)
    context.complete()
    return context
}

private func parse(dateString str: String,
              timeZone: TimeZone?,
              locale: Locale?,
              preferMonthFirst: Bool,
              skipped: Int,
              trimmed: Int) throws -> Context {
    var datestr = str
    var p = Context(dateStr: datestr,
                    timeZone: timeZone,
                    preferMonthFirst: preferMonthFirst,
                    skipped: skipped,
                    trimmed: trimmed)
    var i = 0
    
    // General strategy is to read character by character through the date looking for
    // certain hints of what type of date we are dealing with.
    // Hopefully we only need to read about 5 or 6 characters before
    // we figure it out
    
    //iterChars:
    if let value = try forLoop(condition: i < datestr.count, afterthought: i += 1, body: { () throws -> ForLoopStatement<Context> in
        guard let r = datestr[i] else {
            throw Error.indexOutOfBounds(string: datestr, index: i, state: (p.stateDate, p.stateTime))
        }
        
        #if VERBOSE
        print("i=\(i) r=\(r) state=\(p.stateDate)   \(datestr)")
        #endif
        
        switch p.stateDate {
        // ------- stateDate == dateStart
        case .dateStart:
            if r.isNumber {
                p.stateDate = .dateDigit
            } else if r.isLetter {
                p.stateDate = .dateAlpha
            } else {
                throw Error.unknownError(string: datestr, index: i, state: (p.stateDate, p.stateTime))
            }
        // ------- stateDate == dateDigit
        case .dateDigit:
            switch r {
            case "-", "\u{2212}":
                // 2006-01-02
                // 2013-Feb-03
                // 13-Feb-03
                // 29-Jun-2016
                if i == 4 {
                    p.stateDate = .dateYearDash
                    p.yeari = 0
                    p.yearlen = i
                    p.moi = i + 1
                    p.set(start: 0, value: "2006")
                } else {
                    p.stateDate = .dateDigitDash
                }
            case "/":
                // 03/31/2005
                // 2014/02/24
                p.stateDate = .dateDigitSlash
                if i == 4 {
                    p.yearlen = i
                    p.moi = i + 1
                    p.setYear()
                } else {
                    p.ambiguousMD = true
                    if p.preferMonthFirst {
                        if p.molen == 0 {
                            p.molen = i
                            p.setMonth()
                            p.dayi = i + 1
                        }
                    }
                }
                
            case ".":
                // 3.31.2014
                // 08.21.71
                // 2014.05
                p.stateDate = .dateDigitDot
                if i == 4 {
                    p.yearlen = i
                    p.moi = i + 1
                    p.setYear()
                } else {
                    p.ambiguousMD = true
                    p.moi = 0
                    p.molen = i
                    p.setMonth()
                    p.dayi = i + 1
                }
                
            case " ":
                // 18 January 2018
                // 8 January 2018
                // 8 jan 2018
                // 02 Jan 2018 23:59
                // 02 Jan 2018 23:59:34
                // 12 Feb 2006, 19:17
                // 12 Feb 2006, 19:17:22
                p.stateDate = .dateDigitWs
                p.dayi = 0
                p.daylen = i
            case "年":
                // Chinese Year
                p.stateDate = .dateDigitChineseYear
            case ",":
                throw Error.unknownError(string: datestr, index: i, state: (p.stateDate, p.stateTime))
            default:
                return .continue
            }
            p.part1Len = i
        // ------- stateDate == dateYearDash
        case .dateYearDash:
            // dateYearDashDashT
            //  2006-01-02T15:04:05Z07:00
            // dateYearDashDashWs
            //  2013-04-01 22:43:22
            // dateYearDashAlphaDash
            //   2013-Feb-03
            switch r {
            case "-":
                p.molen = i - p.moi
                p.dayi = i + 1
                p.stateDate = .dateYearDashDash
                p.setMonth()
            default:
                if r.isLetter {
                    p.stateDate = .dateYearDashAlphaDash
                }
            }
        // ------- stateDate == dateYearDashDash
        case .dateYearDashDash:
            // dateYearDashDashT
            //  2006-01-02T15:04:05Z07:00
            // dateYearDashDashWs
            //  2013-04-01 22:43:22
            if r == " " {
                p.daylen = i - p.dayi
                p.stateDate = .dateYearDashDashWs
                p.stateTime = .timeStart
                p.setDay()
                return .break // iterChars
            } else if r == "T" {
                p.daylen = i - p.dayi
                p.stateDate = .dateYearDashDashT
                p.stateTime = .timeStart
                p.setDay()
                return .break // iterChars
            }
        // ------- stateDate == dateYearDashAlphaDash
        case .dateYearDashAlphaDash:
            // 2013-Feb-03
            if r == "-" {
                p.molen = i - p.moi
                p.set(start: p.moi, value: "Jan")
                p.dayi = i + 1
            }
        // ------- stateDate == dateDigitDash
        case .dateDigitDash:
            // 13-Feb-03
            // 29-Jun-2016
            if r.isLetter {
                p.stateDate = .dateDigitDashAlpha
                p.moi = i
            } else {
                throw Error.unknownError(string: datestr, index: i, state: (p.stateDate, p.stateTime))
            }
        // ------- stateDate == dateDigitDashAlpha
        case .dateDigitDashAlpha:
            // 13-Feb-03
            // 28-Feb-03
            // 29-Jun-2016
            if r == "-" {
                p.molen = i - p.moi
                p.set(start: p.moi, value: "Jan")
                p.yeari = i + 1
                p.stateDate = .dateDigitDashAlphaDash
            }
        // ------- stateDate == dateDigitDashAlphaDash
        case .dateDigitDashAlphaDash:
            // 13-Feb-03   ambiguous
            // 28-Feb-03   ambiguous
            // 29-Jun-2016
            if r == " " {
                // we need to find if this was 4 digits, aka year
                // or 2 digits which makes it ambiguous year/day
                let length = i - (p.moi + p.molen + 1)
                if length == 4 {
                    p.yearlen = 4
                    p.set(start: p.yeari, value: "2006")
                    // We now also know that part1 was the day
                    p.dayi = 0
                    p.daylen = p.part1Len
                    p.setDay()
                } else if length == 2 {
                    // We have no idea if this is
                    // yy-mon-dd   OR  dd-mon-yy
                    //
                    // We are going to ASSUME (bad, bad) that it is dd-mon-yy  which is a horible assumption
                    p.ambiguousMD = true
                    p.yearlen = 2
                    p.set(start: p.yeari, value: "06")
                    // We now also know that part1 was the day
                    p.dayi = 0
                    p.daylen = p.part1Len
                    p.setDay()
                }
                p.stateTime = .timeStart
                return .break // iterChars
            }
        // ------- stateDate == dateDigitSlash
        case .dateDigitSlash:
            // 2014/07/10 06:55:38.156283
            // 03/19/2012 10:11:59
            // 04/2/2014 03:00:37
            // 3/1/2012 10:11:59
            // 4/8/2014 22:05
            // 3/1/2014
            // 10/13/2014
            // 01/02/2006
            // 1/2/06
            if r == " " {
                p.stateTime = .timeStart
                if p.yearlen == 0 {
                    p.yearlen = i - p.yeari
                    p.setYear()
                } else if p.daylen == 0 {
                    p.daylen = i - p.dayi
                    p.setDay()
                }
                return .break // iterChars
            } else if r == "/" {
                if p.yearlen > 0 {
                    // 2014/07/10 06:55:38.156283
                    if p.molen == 0 {
                        p.molen = i - p.moi
                        p.setMonth()
                        p.dayi = i + 1
                    }
                } else if p.preferMonthFirst {
                    if p.daylen == 0 {
                        p.daylen = i - p.dayi
                        p.setDay()
                        p.yeari = i + 1
                    }
                }
            }
        // ------- stateDate == dateDigitWs
        case .dateDigitWs:
            // 18 January 2018
            // 8 January 2018
            // 8 jan 2018
            // 1 jan 18
            // 02 Jan 2018 23:59
            // 02 Jan 2018 23:59:34
            // 12 Feb 2006, 19:17
            // 12 Feb 2006, 19:17:22
            if r == " " {
                p.yeari = i + 1
                //p.yearlen = 4
                p.dayi = 0
                p.daylen = p.part1Len
                p.setDay()
                p.stateTime = .timeStart
                if i > p.daylen + " Sep".count { //  November etc
                    // If len greather than space + 3 it must be full month
                    p.stateDate = .dateDigitWsMolong
                } else {
                    // If len=3, the might be Feb or May?  Ie ambigous abbreviated but
                    // we can parse may with either.  BUT, that means the
                    // format may not be correct?
                    // mo := strings.ToLower(datestr[p.daylen+1 : i])
                    p.moi = p.daylen + 1
                    p.molen = i - p.moi
                    p.set(start: p.moi, value: "Jan")
                    p.stateDate = .dateDigitWsMoYear
                }
            }
        // ------- stateDate == dateDigitWsMoYear
        case .dateDigitWsMoYear:
            // 8 jan 2018
            // 02 Jan 2018 23:59
            // 02 Jan 2018 23:59:34
            // 12 Feb 2006, 19:17
            // 12 Feb 2006, 19:17:22
            if r == "," {
                p.yearlen = i - p.yeari
                p.setYear()
                i += 1
                return .break // iterChars
            } else if r == " " {
                p.yearlen = i - p.yeari
                p.setYear()
                return .break // iterChars
            }
        // ------- stateDate == dateDigitWsMolong
        case .dateDigitWsMolong:
            // 18 January 2018
            // 8 January 2018
            break
        // ------- stateDate == dateDigitChineseYear
        case .dateDigitChineseYear:
            // dateDigitChineseYear
            //   2014年04月08日
            //               weekday  %Y年%m月%e日 %A %I:%M %p
            // 2013年07月18日 星期四 10:27 上午
            if r == " " {
                p.stateDate = .dateDigitChineseYearWs
                break
            }
        // ------- stateDate == dateDigitDot
        case .dateDigitDot:
            // This is the 2nd period
            // 3.31.2014
            // 08.21.71
            // 2014.05
            // 2018.09.30
            if r == "." {
                if p.moi == 0 {
                    // 3.31.2014
                    p.daylen = i - p.dayi
                    p.yeari = i + 1
                    p.setDay()
                    p.stateDate = .dateDigitDotDot
                } else {
                    // 2018.09.30
                    //p.molen = 2
                    p.molen = i - p.moi
                    p.dayi = i + 1
                    p.setMonth()
                    p.stateDate = .dateDigitDotDot
                }
            }
        // ------- stateDate == dateDigitDotDot
        case .dateDigitDotDot:
            // iterate all the way through
            break
        // ------- stateDate == dateAlpha
        case .dateAlpha:
            // dateAlphaWS
            //  Mon Jan _2 15:04:05 2006
            //  Mon Jan _2 15:04:05 MST 2006
            //  Mon Jan 02 15:04:05 -0700 2006
            //  Mon Aug 10 15:44:11 UTC+0100 2015
            //  Fri Jul 03 2015 18:04:07 GMT+0100 (GMT Daylight Time)
            //  dateAlphaWSDigit
            //    May 8, 2009 5:57:51 PM
            //    oct 1, 1970
            //  dateAlphaWsMonth
            //    April 8, 2009
            //  dateAlphaWsMore
            //    dateAlphaWsAtTime
            //      January 02, 2006 at 3:04pm MST-07
            //
            //  dateAlphaPeriodWsDigit
            //    oct. 1, 1970
            // dateWeekdayComma
            //   Monday, 02 Jan 2006 15:04:05 MST
            //   Monday, 02-Jan-06 15:04:05 MST
            //   Monday, 02 Jan 2006 15:04:05 -0700
            //   Monday, 02 Jan 2006 15:04:05 +0100
            // dateWeekdayAbbrevComma
            //   Mon, 02 Jan 2006 15:04:05 MST
            //   Mon, 02 Jan 2006 15:04:05 -0700
            //   Thu, 13 Jul 2017 08:58:40 +0100
            //   Tue, 11 Jul 2017 16:28:13 +0200 (CEST)
            //   Mon, 02-Jan-06 15:04:05 MST
            if r == " " {
                //      X
                // April 8, 2009
                if i > 3 {
                    // Check to see if the alpha is name of month?  or Day?
                    if let month = datestr[0..<i]?.lowercased(), isMonthFull(alpha: month, locale: locale) {
                        p.fullMonth = month
                        // len(" 31, 2018")   = 9
                        if datestr.dropFirst(i).count < 10 {
                            // April 8, 2009
                            p.stateDate = .dateAlphaWsMonth
                        } else {
                            p.stateDate = .dateAlphaWsMore
                        }
                        p.dayi = i + 1
                        break
                    } else if let month = datestr[0..<i]?.lowercased(), isMonthShort(alpha: month, locale: locale) {
                        p.moi = 0
                        p.molen = i
                        p.stateDate = .dateAlphaWs
                    }
                } else {
                    // This is possibly ambiguous?  May will parse as either though.
                    // So, it could return in-correct format.
                    // May 05, 2005, 05:05:05
                    // May 05 2005, 05:05:05
                    // Jul 05, 2005, 05:05:05
                    p.stateDate = .dateAlphaWs
                }
                
            } else if r == "," {
                // Mon, 02 Jan 2006
                // p.moi = 0
                // p.molen = i
                if i == 3 {
                    p.stateDate = .dateWeekdayAbbrevComma
                    p.set(start: 0, value: "Mon")
                } else {
                    p.stateDate = .dateWeekdayComma
                    p.skip = i + 2
                    i += 1
                    // TODO:  let's just make this "skip" as we don't need
                    // the mon, monday, they are all superfelous and not needed
                }
            } else if r == "." {
                // sep. 28, 2017
                // jan. 28, 2017
                p.stateDate = .dateAlphaPeriodWsDigit
                if i == 3 {
                    p.molen = i
                    p.set(start: 0, value: "Jan")
                } else if let substring = datestr[0...i-1], i == 4 {
                    // gross
                    datestr = String(substring) + String(datestr.dropFirst(i + 1))
                    return try .return(parse(
                        dateString: datestr,
                        timeZone: timeZone,
                        locale: locale,
                        preferMonthFirst: preferMonthFirst,
                        skipped: skipped,
                        trimmed: trimmed))
                } else {
                    throw Error.unknownError(string: datestr, index: i, state: (p.stateDate, p.stateTime))
                }
            }
            
        // ------- stateDate == dateAlphaWs
        case .dateAlphaWs:
            // dateAlphaWsAlpha
            //   Mon Jan _2 15:04:05 2006
            //   Mon Jan _2 15:04:05 MST 2006
            //   Mon Jan 02 15:04:05 -0700 2006
            //   Fri Jul 03 2015 18:04:07 GMT+0100 (GMT Daylight Time)
            //   Mon Aug 10 15:44:11 UTC+0100 2015
            //  dateAlphaWsDigit
            //    May 8, 2009 5:57:51 PM
            //    May 8 2009 5:57:51 PM
            //    oct 1, 1970
            //    oct 7, "70
            if r.isLetter {
                p.set(start: 0, value: "Mon")
                p.stateDate = .dateAlphaWsAlpha
                p.set(start: i, value: "Jan")
            } else if r.isNumber {
                p.set(start: 0, value: "Jan")
                p.stateDate = .dateAlphaWsDigit
                p.dayi = i
            }
        // ------- stateDate == dateAlphaWs
        case .dateAlphaWsDigit:
            // May 8, 2009 5:57:51 PM
            // May 8 2009 5:57:51 PM
            // oct 1, 1970
            // oct 7, "70
            // oct. 7, 1970
            if r == "," {
                p.daylen = i - p.dayi
                p.setDay()
                p.stateDate = .dateAlphaWsDigitMore
            } else if r == " " {
                p.daylen = i - p.dayi
                p.setDay()
                p.yeari = i + 1
                p.stateDate = .dateAlphaWsDigitMoreWs
            } else if r.isLetter {
                p.stateDate = .dateAlphaWsMonthSuffix
                i -= 1
            }
        // ------- stateDate == dateAlphaWsDigitMore
        case .dateAlphaWsDigitMore:
            //       x
            // May 8, 2009 5:57:51 PM
            // May 05, 2005, 05:05:05
            // May 05 2005, 05:05:05
            // oct 1, 1970
            // oct 7, "70
            if r == " " {
                p.yeari = i + 1
                p.stateDate = .dateAlphaWsDigitMoreWs
            }
        // ------- stateDate == dateAlphaWsDigitMoreWs
        case .dateAlphaWsDigitMoreWs:
            //            x
            // May 8, 2009 5:57:51 PM
            // May 05, 2005, 05:05:05
            // oct 1, 1970
            // oct 7, "70
            if r == "\'" {
                p.yeari = i + 1
            } else if r == " " || r == "," {
                //            x
                // May 8, 2009 5:57:51 PM
                //            x
                // May 8, 2009, 5:57:51 PM
                p.stateDate = .dateAlphaWsDigitMoreWsYear
                p.yearlen = i - p.yeari
                p.setYear()
                p.stateTime = .timeStart
                return .break // iterChars
            }
        // ------- stateDate == dateAlphaWsAlpha
        case .dateAlphaWsAlpha:
            // Mon Jan _2 15:04:05 2006
            // Mon Jan 02 15:04:05 -0700 2006
            // Mon Jan _2 15:04:05 MST 2006
            // Mon Aug 10 15:44:11 UTC+0100 2015
            // Fri Jul 03 2015 18:04:07 GMT+0100 (GMT Daylight Time)
            if r == " " {
                if p.dayi > 0 {
                    p.daylen = i - p.dayi
                    p.setDay()
                    p.yeari = i + 1
                    p.stateDate = .dateAlphaWsAlphaYearmaybe
                    p.stateTime = .timeStart
                }
            } else if r.isNumber {
                if p.dayi == 0 {
                    p.dayi = i
                }
            }
        // ------- stateDate == dateAlphaWsAlphaYearmaybe
        case .dateAlphaWsAlphaYearmaybe:
            //            x
            // Mon Jan _2 15:04:05 2006
            // Fri Jul 03 2015 18:04:07 GMT+0100 (GMT Daylight Time)
            if r == ":" {
                i = i - 3
                p.stateDate = .dateAlphaWsAlpha
                p.yeari = 0
                return .break // iterChars
            } else if r == " " {
                // must be year format, not 15:04
                p.yearlen = i - p.yeari
                p.setYear()
                return .break // iterChars
            }
        // ------- stateDate == dateAlphaWsMonth
        case .dateAlphaWsMonth:
            // April 8, 2009
            // April 8 2009
            switch r {
            case " ", ",":
                //       x
                // June 8, 2009
                //       x
                // June 8 2009
                if p.daylen == 0 {
                    p.daylen = i - p.dayi
                    p.setDay()
                }
            case "s", "S", "r", "R", "t", "T", "n", "N":
                // st, rd, nd, st
                i -= 1
                p.stateDate = .dateAlphaWsMonthSuffix
            default:
                if p.daylen > 0 && p.yeari == 0 {
                    p.yeari = i
                }
            }
        // ------- stateDate == dateAlphaWsMonthMore
        case .dateAlphaWsMonthMore:
            //                  X
            // January 02, 2006, 15:04:05
            // January 02 2006, 15:04:05
            // January 02, 2006 15:04:05
            // January 02 2006 15:04:05
            if r == "," {
                p.yearlen = i - p.yeari
                p.setYear()
                p.stateTime = .timeStart
                i += 1
                return .break // iterChars
            } else if r == " " {
                p.yearlen = i - p.yeari
                p.setYear()
                p.stateTime = .timeStart
                return .break // iterChars
            }
        // ------- stateDate == dateAlphaWsMonthSuffix
        case .dateAlphaWsMonthSuffix:
            //        x
            // April 8th, 2009
            // April 8th 2009
            if r == "t" || r == "T" {
                if p.nextIs(i: i, b: "h") || p.nextIs(i: i, b: "H") {
                    if let prefix = p.datestr[0..<i], let suffix = p.datestr[i+2..<datestr.count] {
                        return try .return(parse(dateString: "\(prefix)\(suffix)",
                            timeZone: timeZone,
                            locale: locale,
                            preferMonthFirst: preferMonthFirst,
                            skipped: skipped,
                            trimmed: trimmed))
                    }
                }
            } else if r == "n" || r == "N" {
                if p.nextIs(i: i, b: "d") || p.nextIs(i: i, b: "D") {
                    if let prefix = p.datestr[0..<i], let suffix = p.datestr[i+2..<datestr.count] {
                        return try .return(parse(
                            dateString: "\(prefix)\(suffix)",
                            timeZone: timeZone,
                            locale: locale,
                            preferMonthFirst: preferMonthFirst,
                            skipped: skipped,
                            trimmed: trimmed))
                    }
                }
            } else if r == "s" || r == "S" {
                if p.nextIs(i: i, b: "t") || p.nextIs(i: i, b: "T") {
                    if let prefix = p.datestr[0..<i], let suffix = p.datestr[i+2..<datestr.count] {
                        return try .return(parse(
                            dateString: "\(prefix)\(suffix)",
                            timeZone: timeZone,
                            locale: locale,
                            preferMonthFirst: preferMonthFirst,
                            skipped: skipped,
                            trimmed: trimmed))
                    }
                }
            } else if r == "r" || r == "R" {
                if p.nextIs(i: i, b: "d") || p.nextIs(i: i, b: "D") {
                    if let prefix = p.datestr[0..<i], let suffix = p.datestr[i+2..<datestr.count] {
                        return try .return(parse(
                            dateString: "\(prefix)\(suffix)",
                            timeZone: timeZone,
                            locale: locale,
                            preferMonthFirst: preferMonthFirst,
                            skipped: skipped,
                            trimmed: trimmed))
                    }
                }
            }
        // ------- stateDate == dateAlphaWsMore
        case .dateAlphaWsMore:
            // January 02, 2006, 15:04:05
            // January 02 2006, 15:04:05
            // January 2nd, 2006, 15:04:05
            // January 2nd 2006, 15:04:05
            // September 17, 2012 at 5:00pm UTC-05
            if r == "," {
                //           x
                // January 02, 2006, 15:04:05
                if p.nextIs(i: i, b: " ") {
                    p.daylen = i - p.dayi
                    p.setDay()
                    p.yeari = i + 2
                    p.stateDate = .dateAlphaWsMonthMore
                    i += 1
                }
                
            } else if r == " " {
                //           x
                // January 02 2006, 15:04:05
                p.daylen = i - p.dayi
                p.setDay()
                p.yeari = i + 1
                p.stateDate = .dateAlphaWsMonthMore
            } else if r.isNumber {
                //         XX
                // January 02, 2006, 15:04:05
                return .continue
            } else if r.isLetter {
                //          X
                // January 2nd, 2006, 15:04:05
                p.daylen = i - p.dayi
                p.setDay()
                p.stateDate = .dateAlphaWsMonthSuffix
                i -= 1
            }
        // ------- stateDate == dateAlphaPeriodWsDigit
        case .dateAlphaPeriodWsDigit:
            //    oct. 7, "70
            if r == " " {
                // continue
            } else if r.isNumber {
                p.stateDate = .dateAlphaWsDigit
                p.dayi = i
            } else {
                throw Error.unknownError(string: datestr, index: i, state: (p.stateDate, p.stateTime))
            }
        // ------- stateDate == dateWeekdayComma
        case .dateWeekdayComma:
            // Monday, 02 Jan 2006 15:04:05 MST
            // Monday, 02 Jan 2006 15:04:05 -0700
            // Monday, 02 Jan 2006 15:04:05 +0100
            // Monday, 02-Jan-06 15:04:05 MST
            if p.dayi == 0 {
                p.dayi = i
            }
            if r == " " || r == "-" {
                if p.moi == 0 {
                    p.moi = i + 1
                    p.daylen = i - p.dayi
                    p.setDay()
                } else if p.yeari == 0 {
                    p.yeari = i + 1
                    p.molen = i - p.moi
                    p.set(start: p.moi, value: "Jan")
                } else {
                    p.stateTime = .timeStart
                    return .break // iterChars
                }
            }
        // ------- stateDate == dateWeekdayAbbrevComma
        case .dateWeekdayAbbrevComma:
            // Mon, 02 Jan 2006 15:04:05 MST
            // Mon, 02 Jan 2006 15:04:05 -0700
            // Thu, 13 Jul 2017 08:58:40 +0100
            // Thu, 4 Jan 2018 17:53:36 +0000
            // Tue, 11 Jul 2017 16:28:13 +0200 (CEST)
            // Mon, 02-Jan-06 15:04:05 MST
            if r == " " || r == "-" {
                if p.dayi == 0 {
                    p.dayi = i + 1
                } else if p.moi == 0 {
                    p.daylen = i - p.dayi
                    p.setDay()
                    p.moi = i + 1
                } else if p.yeari == 0 {
                    p.molen = i - p.moi
                    p.set(start: p.moi, value: "Jan")
                    p.yeari = i + 1
                } else {
                    p.yearlen = i - p.yeari
                    p.setYear()
                    p.stateTime = .timeStart
                    return .break // iterChars
                }
            }
        // ------- else...
        case .dateYearDashDashWs, .dateYearDashDashT, .dateDigitChineseYearWs, .dateAlphaWsDigitMoreWsYear, .dateAlphaWsAtTime:
            return .break // iterChars
        }
        
        return .continue
    }).wrapped { return value }
    
    p.coalesceDate(end: i)
    
    if p.stateTime == .timeStart {
        // increment first one, since the i += 1 occurs at end of loop
        if i < p.datestr.count {
            i += 1
        }
        // ensure we skip any whitespace prefix
        _ = forLoop(condition: i < datestr.count, afterthought: i += 1, body: { () -> ForLoopStatement<Void> in
            if datestr[i] != " " {
                return .break
            }
            return .continue
        })
        
        //iterTimeChars:
        if let value = try forLoop(condition: i < datestr.count, afterthought: i += 1, body: { () throws -> ForLoopStatement<Context> in
            guard let r = datestr[i] else {
                throw Error.indexOutOfBounds(string: datestr, index: i, state: (p.stateDate, p.stateTime))
            }
            
            #if VERBOSE
            print("\(i) \(r) \(p.stateTime) iterTimeChars  \(p.ds()) \(p.ts())")
            #endif
            
            switch p.stateTime {
            // ------- stateTime == timeStart
            case .timeStart:
                // 22:43:22
                // 22:43
                // timeComma
                //   08:20:13,787
                // timeWs
                //   05:24:37 PM
                //   06:20:00 UTC
                //   06:20:00 UTC-05
                //   00:12:00 +0000 UTC
                //   22:18:00 +0000 UTC m=+0.000000001
                //   15:04:05 -0700
                //   15:04:05 -07:00
                //   15:04:05 2008
                // timeOffset
                //   03:21:51+00:00
                //   19:55:00+0100
                // timePeriod
                //   17:24:37.3186369
                //   00:07:31.945167
                //   18:31:59.257000000
                //   00:00:00.000
                //   timePeriodOffset
                //     19:55:00.799+0100
                //     timePeriodOffsetColon
                //       15:04:05.999-07:00
                //   timePeriodWs
                //     timePeriodWsOffset
                //       00:07:31.945167 +0000
                //       00:00:00.000 +0000
                //     timePeriodWsOffsetAlpha
                //       00:07:31.945167 +0000 UTC
                //       22:18:00.001 +0000 UTC m=+0.000000001
                //       00:00:00.000 +0000 UTC
                //     timePeriodWsAlpha
                //       06:20:00.000 UTC
                if p.houri == 0 {
                    p.houri = i
                }
                switch r {
                case "-", "+":
                    //   03:21:51+00:00
                    p.stateTime = .timeOffset
                    if p.seci == 0 {
                        // 22:18+0530
                        p.minlen = i - p.mini
                    } else {
                        p.seclen = i - p.seci
                    }
                    p.offseti = i
                case ".", ",":
                    // for some reason go won't parse comma, but in swift you should not worry about that
                    // 2014-05-11 08:20:13,787
                    p.stateTime = .timePeriod
                    p.seclen = i - p.seci
                    p.msi = i + 1
                case "Z":
                    p.stateTime = .timeZ
                    if p.seci == 0 {
                        p.minlen = i - p.mini
                    } else {
                        p.seclen = i - p.seci
                    }
                case "a", "A":
                    if p.nextIs(i: i, b: "t") || p.nextIs(i: i, b: "T") {
                        //                    x
                        // September 17, 2012 at 5:00pm UTC-05
                        i += 1 // skip t
                        if p.nextIs(i: i, b: " ") {
                            //                      x
                            // September 17, 2012 at 5:00pm UTC-05
                            i += 1         // skip '
                            p.houri = 0 // reset hour
                        }
                    } else {
                        if r == "a" && p.nextIs(i: i, b: "m") {
                            p.twelveHourFormat = true
                            p.coalesceTime(end: i)
                            p.set(start: i, value: "pm")
                        } else if r == "A" && p.nextIs(i: i, b: "M") {
                            p.twelveHourFormat = true
                            p.coalesceTime(end: i)
                            p.set(start: i, value: "PM")
                        }
                    }
                    
                case "p", "P":
                    // Could be AM/PM
                    if r == "p" && p.nextIs(i: i, b: "m") {
                        p.twelveHourFormat = true
                        p.coalesceTime(end: i)
                        p.set(start: i, value: "pm")
                    } else if r == "P" && p.nextIs(i: i, b: "M") {
                        p.twelveHourFormat = true
                        p.coalesceTime(end: i)
                        p.set(start: i, value: "PM")
                    }
                case " ":
                    p.coalesceTime(end: i)
                    p.stateTime = .timeWs
                case ":":
                    if p.mini == 0 {
                        p.mini = i + 1
                        p.hourlen = i - p.houri
                    } else if p.seci == 0 {
                        p.seci = i + 1
                        p.minlen = i - p.mini
                    }
                default:
                    break
                }
            // ------- stateTime == timeOffset
            case .timeOffset:
                // 19:55:00+0100
                // timeOffsetColon
                //   15:04:05+07:00
                //   15:04:05-07:00
                if r == ":" {
                    p.stateTime = .timeOffsetColon
                }
            // ------- stateTime == timeWs
            case .timeWs:
                // timeWsAlpha
                //   06:20:00 UTC
                //   06:20:00 UTC-05
                //   15:44:11 UTC+0100 2015
                //   18:04:07 GMT+0100 (GMT Daylight Time)
                //   17:57:51 MST 2009
                //   timeWsAMPMMaybe
                //     05:24:37 PM
                // timeWsOffset
                //   15:04:05 -0700
                //   00:12:00 +0000 UTC
                //   timeWsOffsetColon
                //     15:04:05 -07:00
                //     17:57:51 -0700 2009
                //     timeWsOffsetColonAlpha
                //       00:12:00 +00:00 UTC
                // timeWsYear
                //     00:12:00 2008
                // timeZ
                //   15:04:05.99Z
                switch r {
                case "A", "P":
                    // Could be AM/PM or could be PST or similar
                    p.tzi = i
                    p.stateTime = .timeWsAMPMMaybe
                case "+", "-":
                    p.offseti = i
                    p.stateTime = .timeWsOffset
                default:
                    if r.isLetter {
                        // 06:20:00 UTC
                        // 06:20:00 UTC-05
                        // 15:44:11 UTC+0100 2015
                        // 17:57:51 MST 2009
                        p.tzi = i
                        p.stateTime = .timeWsAlpha
                        //break iterTimeChars
                    } else if r.isNumber {
                        // 00:12:00 2008
                        p.stateTime = .timeWsYear
                        p.yeari = i
                    }
                }
            // ------- stateTime == timeWsAlpha
            case .timeWsAlpha:
                // 06:20:00 UTC
                // 06:20:00 UTC-05
                // timeWsAlphaWs
                //   17:57:51 MST 2009
                // timeWsAlphaZoneOffset
                // timeWsAlphaZoneOffsetWs
                //   timeWsAlphaZoneOffsetWsExtra
                //     18:04:07 GMT+0100 (GMT Daylight Time)
                //   timeWsAlphaZoneOffsetWsYear
                //     15:44:11 UTC+0100 2015
                if r == "+" || r == "-" {
                    p.tzlen = i - p.tzi
                    if p.tzlen == 4 {
                        p.set(start: p.tzi, value: " MST")
                    } else if p.tzlen == 3 {
                        p.set(start: p.tzi, value: "MST")
                    }
                    p.stateTime = .timeWsAlphaZoneOffset
                    p.offseti = i
                } else if r == " " {
                    // 17:57:51 MST 2009
                    p.tzlen = i - p.tzi
                    if p.tzlen == 4 {
                        p.set(start: p.tzi, value: " MST")
                    } else if p.tzlen == 3 {
                        p.set(start: p.tzi, value: "MST")
                    }
                    p.stateTime = .timeWsAlphaWs
                    p.yeari = i + 1
                }
            // ------- stateTime == timeWsAlphaWs
            case .timeWsAlphaWs:
                //   17:57:51 MST 2009
                break
            // ------- stateTime == timeWsAlphaZoneOffset
            case .timeWsAlphaZoneOffset:
                // 06:20:00 UTC-05
                // timeWsAlphaZoneOffset
                // timeWsAlphaZoneOffsetWs
                //   timeWsAlphaZoneOffsetWsExtra
                //     18:04:07 GMT+0100 (GMT Daylight Time)
                //   timeWsAlphaZoneOffsetWsYear
                //     15:44:11 UTC+0100 2015
                if r == " " {
                    p.set(start: p.offseti, value: "-0700")
                    p.yeari = i + 1
                    p.stateTime = .timeWsAlphaZoneOffsetWs
                }
            // ------- stateTime == timeWsAlphaZoneOffsetWs
            case .timeWsAlphaZoneOffsetWs:
                // timeWsAlphaZoneOffsetWs
                //   timeWsAlphaZoneOffsetWsExtra
                //     18:04:07 GMT+0100 (GMT Daylight Time)
                //   timeWsAlphaZoneOffsetWsYear
                //     15:44:11 UTC+0100 2015
                if r.isNumber {
                    p.stateTime = .timeWsAlphaZoneOffsetWsYear
                } else {
                    p.extra = i - 1
                    p.stateTime = .timeWsAlphaZoneOffsetWsExtra
                }
            // ------- stateTime == timeWsAlphaZoneOffsetWsYear
            case .timeWsAlphaZoneOffsetWsYear:
                // 15:44:11 UTC+0100 2015
                if r.isNumber {
                    p.yearlen = i - p.yeari + 1
                    if p.yearlen == 4 {
                        p.setYear()
                    }
                }
            // ------- stateTime == timeWsAMPMMaybe
            case .timeWsAMPMMaybe:
                // timeWsAMPMMaybe
                //   timeWsAMPM
                //     05:24:37 PM
                //   timeWsAlpha
                //     00:12:00 PST
                //     15:44:11 UTC+0100 2015
                if r == "M" {
                    //return parse("2006-01-02 03:04:05 PM", datestr, loc)
                    p.stateTime = .timeWsAMPM
                    p.twelveHourFormat = true
                    p.set(start: i-1, value: "PM")
                    if p.hourlen == 2 {
                        p.set(start: p.houri, value: "03")
                    } else if p.hourlen == 1 {
                        p.set(start: p.houri, value: "3")
                    }
                } else {
                    p.stateTime = .timeWsAlpha
                }
            // ------- stateTime == timeWsOffset
            case .timeWsOffset:
                // timeWsOffset
                //   15:04:05 -0700
                //   timeWsOffsetWsOffset
                //     17:57:51 -0700 -07
                //   timeWsOffsetWs
                //     17:57:51 -0700 2009
                //     00:12:00 +0000 UTC
                //   timeWsOffsetColon
                //     15:04:05 -07:00
                //     timeWsOffsetColonAlpha
                //       00:12:00 +00:00 UTC
                if r == ":" {
                    p.stateTime = .timeWsOffsetColon
                } else if r == " " {
                    p.set(start: p.offseti, value: "-0700")
                    p.yeari = i + 1
                    p.stateTime = .timeWsOffsetWs
                }
            // ------- stateTime == timeWsOffsetWs
            case .timeWsOffsetWs:
                // 17:57:51 -0700 2009
                // 00:12:00 +0000 UTC
                // 22:18:00.001 +0000 UTC m=+0.000000001
                // w Extra
                //   17:57:51 -0700 -07
                switch r {
                case "=":
                    // eff you golang
                    if datestr[i-1] == "m" {
                        p.extra = i - 2
                        p.trimExtra()
                        break
                    }
                case "+", "-":
                    // This really doesn't seem valid, but for some reason when round-tripping a go date
                    // their is an extra +03 printed out.  seems like go bug to me, but, parsing anyway.
                    // 00:00:00 +0300 +03
                    // 00:00:00 +0300 +0300
                    p.extra = i - 1
                    p.stateTime = .timeWsOffset
                    p.trimExtra()
                    break
                default:
                    if r.isNumber {
                        p.yearlen = i - p.yeari + 1
                        if p.yearlen == 4 {
                            p.setYear()
                        }
                    } else if r.isLetter {
                        if p.tzi == 0 {
                            p.tzi = i
                            p.tzlen = 1
                        } else if (p.tzi + p.tzlen) == i {
                            p.tzlen += 1
                        }
                    }
                }
            // ------- stateTime == timeWsOffsetColon
            case .timeWsOffsetColon:
                // timeWsOffsetColon
                //   15:04:05 -07:00
                //   timeWsOffsetColonAlpha
                //     2015-02-18 00:12:00 +00:00 UTC
                if r.isLetter {
                    // 2015-02-18 00:12:00 +00:00 UTC
                    p.stateTime = .timeWsOffsetColonAlpha
                    return .break // iterTimeChars
                }
            // ------- stateTime == timePeriod
            case .timePeriod:
                // 15:04:05.999999999+07:00
                // 15:04:05.999999999-07:00
                // 15:04:05.999999+07:00
                // 15:04:05.999999-07:00
                // 15:04:05.999+07:00
                // 15:04:05.999-07:00
                // timePeriod
                //   17:24:37.3186369
                //   00:07:31.945167
                //   18:31:59.257000000
                //   00:00:00.000
                //   timePeriodOffset
                //     19:55:00.799+0100
                //     timePeriodOffsetColon
                //       15:04:05.999-07:00
                //   timePeriodWs
                //     timePeriodWsOffset
                //       00:07:31.945167 +0000
                //       00:00:00.000 +0000
                //       With Extra
                //         00:00:00.000 +0300 +03
                //     timePeriodWsOffsetAlpha
                //       00:07:31.945167 +0000 UTC
                //       00:00:00.000 +0000 UTC
                //       22:18:00.001 +0000 UTC m=+0.000000001
                //     timePeriodWsAlpha
                //       06:20:00.000 UTC
                if r == " " {
                    p.mslen = i - p.msi
                    p.stateTime = .timePeriodWs
                } else if r == "+" || r ==  "-" {
                    // This really shouldn't happen
                    p.mslen = i - p.msi
                    p.offseti = i
                    p.stateTime = .timePeriodOffset
                } else if r.isLetter {
                    // 06:20:00.000 UTC
                    p.mslen = i - p.msi
                    p.stateTime = .timePeriodWsAlpha
                }
            // ------- stateTime == timePeriodOffset
            case .timePeriodOffset:
                // timePeriodOffset
                //   19:55:00.799+0100
                //   timePeriodOffsetColon
                //     15:04:05.999-07:00
                //     13:31:51.999-07:00 MST
                if r == ":" {
                    p.stateTime = .timePeriodOffsetColon
                }
            // ------- stateTime == timePeriodOffsetColon
            case .timePeriodOffsetColon:
                // timePeriodOffset
                //   timePeriodOffsetColon
                //     15:04:05.999-07:00
                //     13:31:51.999 -07:00 MST
                if r == " " {
                    p.set(start: p.offseti, value: "-07:00")
                    p.stateTime = .timePeriodOffsetColonWs
                    p.tzi = i + 1
                }
            // ------- stateTime == timePeriodOffsetColonWs
            case .timePeriodOffsetColonWs:
                // continue
                break
            // ------- stateTime == timePeriodWs
            case .timePeriodWs:
                // timePeriodWs
                //   timePeriodWsOffset
                //     00:07:31.945167 +0000
                //     00:00:00.000 +0000
                //   timePeriodWsOffsetAlpha
                //     00:07:31.945167 +0000 UTC
                //     00:00:00.000 +0000 UTC
                //   timePeriodWsOffsetColon
                //     13:31:51.999 -07:00 MST
                //   timePeriodWsAlpha
                //     06:20:00.000 UTC
                if p.offseti == 0 {
                    p.offseti = i
                }
                switch r {
                case "+", "-":
                    p.mslen = i - p.msi - 1
                    p.stateTime = .timePeriodWsOffset
                default:
                    if r.isLetter {
                        //     00:07:31.945167 +0000 UTC
                        //     00:00:00.000 +0000 UTC
                        p.stateTime = .timePeriodWsOffsetWsAlpha
                        return .break // iterTimeChars
                    }
                }
            // ------- stateTime == timePeriodWsOffset
            case .timePeriodWsOffset:
                // timePeriodWs
                //   timePeriodWsOffset
                //     00:07:31.945167 +0000
                //     00:00:00.000 +0000
                //     With Extra
                //       00:00:00.000 +0300 +03
                //   timePeriodWsOffsetAlpha
                //     00:07:31.945167 +0000 UTC
                //     00:00:00.000 +0000 UTC
                //     03:02:00.001 +0300 MSK m=+0.000000001
                //   timePeriodWsOffsetColon
                //     13:31:51.999 -07:00 MST
                //   timePeriodWsAlpha
                //     06:20:00.000 UTC
                switch r {
                case ":":
                    p.stateTime = .timePeriodWsOffsetColon
                case " ":
                    p.set(start: p.offseti, value: "-0700")
                case "+", "-":
                    // This really doesn't seem valid, but for some reason when round-tripping a go date
                    // their is an extra +03 printed out.  seems like go bug to me, but, parsing anyway.
                    // 00:00:00.000 +0300 +03
                    // 00:00:00.000 +0300 +0300
                    p.extra = i - 1
                    p.trimExtra()
                    break
                default:
                    if r.isLetter {
                        // 00:07:31.945167 +0000 UTC
                        // 00:00:00.000 +0000 UTC
                        // 03:02:00.001 +0300 MSK m=+0.000000001
                        if r == "m" {
                            p.stateTime = .timePeriodWsOffsetWsAlpha
                        } else if p.tzi == 0 {
                            p.tzi = i
                            p.tzlen = 1
                        } else if (p.tzi + p.tzlen) == i {
                            p.tzlen += 1
                        }
                    }
                }
            // ------- stateTime == timePeriodWsOffsetWsAlpha
            case .timePeriodWsOffsetWsAlpha:
                // 03:02:00.001 +0300 MSK m=+0.000000001
                // eff you golang
                if r == "=" && datestr[i-1] == "m" {
                    p.extra = i - 2
                    p.trimExtra()
                    break
                }
            // ------- stateTime == timePeriodWsOffsetColon
            case .timePeriodWsOffsetColon:
                // 13:31:51.999 -07:00 MST
                switch r {
                case " ":
                    p.set(start: p.offseti, value: "-07:00")
                default:
                    if r.isLetter {
                        // 13:31:51.999 -07:00 MST
                        p.tzi = i
                        p.stateTime = .timePeriodWsOffsetColonAlpha
                    }
                }
            // ------- stateTime == timePeriodWsOffsetColonAlpha
            case .timePeriodWsOffsetColonAlpha:
                // continue
                break
            // ------- stateTime == timeZ
            case .timeZ:
                // timeZ
                //   15:04:05.99Z
                // With a time-zone at end after Z
                // 2006-01-02T15:04:05.999999999Z07:00
                // 2006-01-02T15:04:05Z07:00
                // RFC3339     = "2006-01-02T15:04:05Z07:00"
                // RFC3339Nano = "2006-01-02T15:04:05.999999999Z07:00"
                if r.isNumber {
                    p.stateTime = .timeZDigit
                }
            // ------- else...
            case .timeIgnore, .timeWsAlphaZoneOffsetWsExtra, .timeWsAMPM, .timeWsOffsetColonAlpha, .timeWsYear, .timeOffsetColon, .timeAlpha, .timePeriodWsAlpha, .timePeriodWsOffsetWs, .timeZDigit:
                break
            }
            
            return .continue
        }).wrapped { return value }
        
        if p.tzi > 0 && p.tzlen > 0 {
            p.set(start: p.tzi, value: "MST", length: p.tzlen)
        }
        
        switch p.stateTime {
        // ------- stateTime == timeWsAlphaWs
        case .timeWsAlphaWs:
            p.yearlen = i - p.yeari
            p.setYear()
        // ------- stateTime == timeWsYear
        case .timeWsYear:
            p.yearlen = i - p.yeari
            p.setYear()
        // ------- stateTime == timeWsAlphaZoneOffsetWsExtra
        case .timeWsAlphaZoneOffsetWsExtra:
            p.trimExtra()
        // ------- stateTime == timeWsAlphaZoneOffset
        case .timeWsAlphaZoneOffset:
            // 06:20:00 UTC-05
            if i-p.offseti < 4 {
                p.set(start: p.offseti, value: "-07")
            } else {
                p.set(start: p.offseti, value: "-0700")
            }
        // ------- stateTime == timePeriod
        case .timePeriod:
            p.mslen = i - p.msi
        // ------- stateTime == timeOffset
        case .timeOffset:
            // 19:55:00+0100
            p.set(start: p.offseti, value: "-0700")
        // ------- stateTime == timeWsOffset
        case .timeWsOffset:
            p.set(start: p.offseti, value: "-0700")
        // ------- stateTime == timeWsOffsetWs
        case .timeWsOffsetWs:
            // 17:57:51 -0700 2009
            // 00:12:00 +0000 UTC
            break
        // ------- stateTime == timeWsOffsetColon
        case .timeWsOffsetColon:
            // 17:57:51 -07:00
            p.set(start: p.offseti, value: "-07:00")
        // ------- stateTime == timeOffsetColon
        case .timeOffsetColon:
            // 15:04:05+07:00
            p.set(start: p.offseti, value: "-07:00")
        // ------- stateTime == timePeriodOffset
        case .timePeriodOffset:
            // 19:55:00.799+0100
            p.set(start: p.offseti, value: "-0700")
        // ------- stateTime == timePeriodOffsetColon
        case .timePeriodOffsetColon:
            p.set(start: p.offseti, value: "-07:00")
        // ------- stateTime == timePeriodWsOffsetColonAlpha
        case .timePeriodWsOffsetColonAlpha:
            p.tzlen = i - p.tzi
            p.set(start: p.tzi, value: "MST", length: p.tzlen)
        // ------- stateTime == timePeriodWsOffset
        case .timePeriodWsOffset:
            p.set(start: p.offseti, value: "-0700")
        // ------- stateTime == timeWsAlpha
        case .timeWsAlpha:
            if p.tzi > 0 && p.tzlen == 0 {
                p.set(start: p.tzi, value: "MST")
            }
        // ------- else...
        case .timeIgnore, .timeStart, .timeWs, .timeWsAlphaZoneOffsetWs, .timeWsAlphaZoneOffsetWsYear, .timeWsAMPMMaybe, .timeWsAMPM, .timeWsOffsetColonAlpha, .timeAlpha, .timePeriodOffsetColonWs, .timePeriodWs, .timePeriodWsAlpha, .timePeriodWsOffsetWs, .timePeriodWsOffsetWsAlpha, .timePeriodWsOffsetColon, .timeZ, .timeZDigit:
            break
        }
        
        p.coalesceTime(end: i)
    }
    
    if p.molen > 3 {
        p.set(start: p.moi, value: "Jan", length: p.molen)
    }
    
    switch p.stateDate {
    // ------- stateDate == dateDigit
    case .dateDigit:
        // unixy timestamps ish
        //  example              ct type
        //  1499979655583057426  19 nanoseconds
        //  1499979795437000     16 micro-seconds
        //  20180722105203       14 yyyyMMddhhmmss
        //  1499979795437        13 milliseconds
        //  1332151919           10 seconds
        //  20140601             8  yyyymmdd
        //  2014                 4  yyyy
        var t: Date?
        if datestr.count == "1499979655583057426".count { // 19
            // nano-seconds
            if let nanoSecs = Double(datestr) {
                t = Date(timeIntervalSince1970: nanoSecs/1000000000)
            }
        } else if datestr.count == "1499979795437000".count { // 16
            // micro-seconds
            if let microSecs = Double(datestr) {
                t = Date(timeIntervalSince1970: microSecs/1000000)
            }
        } else if datestr.count == "yyyyMMddhhmmss".count { // 14
            // yyyyMMddhhmmss
            p.format = Array("20060102150405")
            return p
        } else if datestr.count == "1332151919000".count { // 13
            if let miliSecs = Double(datestr) {
                t = Date(timeIntervalSince1970: miliSecs/1000)
            }
        } else if datestr.count == "1332151919".count { //10
            if let secs = Double(datestr) {
                t = Date(timeIntervalSince1970: secs)
            }
        } else if datestr.count == "20140601".count {
            p.format = Array("20060102")
            return p
        } else if datestr.count == "2014".count {
            p.format = Array("2006")
            return p
        } else if datestr.count < 4 {
            throw Error.tooShortFormat(string: datestr, index: i, state: (p.stateDate, p.stateTime))
        } else {
            t = nil
        }
        if let t = t {
            if let loc = timeZone {
                p.t = t.addingTimeInterval(TimeInterval(-loc.secondsFromGMT(for: t)))
            } else {
                p.t = t
            }
            return p
        }
    // ------- stateDate == dateYearDash
    case .dateYearDash:
        // 2006-01
        return p
    // ------- stateDate == dateYearDashDash
    case .dateYearDashDash:
        // 2006-01-02
        // 2006-1-02
        // 2006-1-2
        // 2006-01-2
        return p
    // ------- stateDate == dateYearDashAlphaDash
    case .dateYearDashAlphaDash:
        // 2013-Feb-03
        // 2013-Feb-3
        p.daylen = i - p.dayi
        p.setDay()
        return p
    // ------- stateDate == dateYearDashDashWs
    case .dateYearDashDashWs:
        // 2013-04-01
        return p
    // ------- stateDate == dateYearDashDashT
    case .dateYearDashDashT:
        return p
    // ------- stateDate == dateDigitDashAlphaDash
    case .dateDigitDashAlphaDash:
        // 13-Feb-03   ambiguous
        // 28-Feb-03   ambiguous
        // 29-Jun-2016
        return p
    // ------- stateDate == dateDigitDot
    case .dateDigitDot:
        // 2014.05
        p.molen = i - p.moi
        p.setMonth()
        return p
    // ------- stateDate == dateDigitDotDot
    case .dateDigitDotDot:
        // 03.31.1981
        // 3.31.2014
        // 3.2.1981
        // 3.2.81
        // 08.21.71
        // 2018.09.30
        return p
    // ------- stateDate == dateDigitWsMoYear
    case .dateDigitWsMoYear:
        // 2 Jan 2018
        // 2 Jan 18
        // 2 Jan 2018 23:59
        // 02 Jan 2018 23:59
        // 12 Feb 2006, 19:17
        return p
    // ------- stateDate == dateDigitWsMolong
    case .dateDigitWsMolong:
        // 18 January 2018
        // 8 January 2018
        if p.daylen == 2 {
            p.format = Array("02 January 2006")
            return p
        }
        p.format = Array("2 January 2006")
        return p // parse("2 January 2006", datestr, loc)
    // ------- stateDate == dateAlphaWsMonth
    case .dateAlphaWsMonth:
        p.yearlen = i - p.yeari
        p.setYear()
        return p
    // ------- stateDate == dateAlphaWsMonthMore
    case .dateAlphaWsMonthMore:
        return p
    // ------- stateDate == dateAlphaWsDigitMoreWs
    case .dateAlphaWsDigitMoreWs:
        // oct 1, 1970
        p.yearlen = i - p.yeari
        p.setYear()
        return p
    // ------- stateDate == dateAlphaWsDigitMoreWsYear
    case .dateAlphaWsDigitMoreWsYear:
        // May 8, 2009 5:57:51 PM
        // Jun 7, 2005, 05:57:51
        return p
    // ------- stateDate == dateAlphaWsAlpha
    case .dateAlphaWsAlpha:
        return p
    // ------- stateDate == dateAlphaWsAlphaYearmaybe
    case .dateAlphaWsAlphaYearmaybe:
        return p
    // ------- stateDate == dateDigitSlash
    case .dateDigitSlash:
        // 3/1/2014
        // 10/13/2014
        // 01/02/2006
        // 2014/10/13
        return p
    // ------- stateDate == dateDigitChineseYear
    case .dateDigitChineseYear:
        // dateDigitChineseYear
        //   2014年04月08日
        p.format = Array("2006年01月02日")
        return p
    // ------- stateDate == dateDigitChineseYearWs
    case .dateDigitChineseYearWs:
        p.format = Array("2006年01月02日 15:04:05")
        return p
    // ------- stateDate == dateWeekdayComma
    case .dateWeekdayComma:
        // Monday, 02 Jan 2006 15:04:05 -0700
        // Monday, 02 Jan 2006 15:04:05 +0100
        // Monday, 02-Jan-06 15:04:05 MST
        return p
    // ------- stateDate == dateWeekdayAbbrevComma
    case .dateWeekdayAbbrevComma:
        // Mon, 02-Jan-06 15:04:05 MST
        // Mon, 02 Jan 2006 15:04:05 MST
        return p
    // ------- else...
    case .dateStart, .dateDigitDash, .dateDigitDashAlpha, .dateDigitWs, .dateAlpha, .dateAlphaWs, .dateAlphaWsDigit, .dateAlphaWsDigitMore, .dateAlphaWsMonthSuffix, .dateAlphaWsMore, .dateAlphaWsAtTime, .dateAlphaPeriodWsDigit:
        break
    }
    
    throw Error.unknownError(string: datestr, index: i, state: (p.stateDate, p.stateTime))
}
