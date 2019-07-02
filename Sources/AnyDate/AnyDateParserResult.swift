/*
 The MIT License (MIT)
 
 Copyright (c) 2019 Hèctor Marquès Ranea
 
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

extension AnyDateParser {
    public struct Result {
        let context: Context
        
        public let timeZone: TimeZone?
        public let locale: Locale?
        public let referenceLayout: String
        public let dateFormatterHeuristics: Bool
        public let string: String
        public let dateFormat: String
        
        /// *mm/dd vs dd/mm**
        public var isAmbiguous: Bool {
            return context.ambiguousMD
        }
        
        public var dateRange: Range<String.Index> {
            let lowerIndex = string.index(string.startIndex, offsetBy: context.skipped)
            let upperIndex = string.index(string.endIndex, offsetBy: -context.trimmed)
            return Range<String.Index>(uncheckedBounds: (lower: lowerIndex, upper: upperIndex))
        }
        
        public var dateString: String {
            return context.datestr
        }
        
        private var dateFormatter: DateFormatter? {
            guard context.t == nil else { return nil }
            let formatter = DateFormatter()
            formatter.isLenient = dateFormatterHeuristics
            formatter.locale = locale
            formatter.timeZone = timeZone
            formatter.dateFormat = dateFormat
            formatter.timeZone = timeZone
            return formatter
        }
        
        public func date() throws -> Date {
            if let date = context.t {
                return date
            }
            guard let dateFormatter = self.dateFormatter else { throw buildError(dateString: dateString, dateFormatter: nil)  }
            if let date = dateFormatter.date(from: dateString) {
                return date
            }
            throw buildError(dateString: dateString, dateFormatter: dateFormatter)
        }
        
        private func buildError(dateString: String, dateFormatter: DateFormatter?) -> Error {
            let expectedLayout = dateFormatter?.string(from: AnyDateParser.referenceDate)
            if expectedLayout == dateString {
                return Error.invalidDateString(string: string,
                                               layout: referenceLayout,
                                               format: dateFormatter?.dateFormat)
            } else {
                return Error.invalidDateFormat(string: string,
                                               layout: referenceLayout,
                                               format: dateFormatter?.dateFormat)
            }

        }
    }
}
