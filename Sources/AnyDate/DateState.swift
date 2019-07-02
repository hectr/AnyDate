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

public enum DateState {
    case dateStart
    case dateDigit
    case dateYearDash
    case dateYearDashAlphaDash
    case dateYearDashDash
    case dateYearDashDashWs
    case dateYearDashDashT
    case dateDigitDash
    case dateDigitDashAlpha
    case dateDigitDashAlphaDash
    case dateDigitDot
    case dateDigitDotDot
    case dateDigitSlash
    case dateDigitChineseYear
    case dateDigitChineseYearWs
    case dateDigitWs
    case dateDigitWsMoYear
    case dateDigitWsMolong
    case dateAlpha
    case dateAlphaWs
    case dateAlphaWsDigit
    case dateAlphaWsDigitMore
    case dateAlphaWsDigitMoreWs
    case dateAlphaWsDigitMoreWsYear
    case dateAlphaWsMonth
    case dateAlphaWsMonthMore
    case dateAlphaWsMonthSuffix
    case dateAlphaWsMore
    case dateAlphaWsAtTime
    case dateAlphaWsAlpha
    case dateAlphaWsAlphaYearmaybe
    case dateAlphaPeriodWsDigit
    case dateWeekdayComma
    case dateWeekdayAbbrevComma
}
