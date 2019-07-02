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

public enum TimeState {
    case timeIgnore
    case timeStart
    case timeWs
    case timeWsAlpha
    case timeWsAlphaWs
    case timeWsAlphaZoneOffset
    case timeWsAlphaZoneOffsetWs
    case timeWsAlphaZoneOffsetWsYear
    case timeWsAlphaZoneOffsetWsExtra
    case timeWsAMPMMaybe
    case timeWsAMPM
    case timeWsOffset
    case timeWsOffsetWs
    case timeWsOffsetColonAlpha
    case timeWsOffsetColon
    case timeWsYear
    case timeOffset
    case timeOffsetColon
    case timeAlpha
    case timePeriod
    case timePeriodOffset
    case timePeriodOffsetColon
    case timePeriodOffsetColonWs
    case timePeriodWs
    case timePeriodWsAlpha
    case timePeriodWsOffset
    case timePeriodWsOffsetWs
    case timePeriodWsOffsetWsAlpha
    case timePeriodWsOffsetColon
    case timePeriodWsOffsetColonAlpha
    case timeZ
    case timeZDigit
}
