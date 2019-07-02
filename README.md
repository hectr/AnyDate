# AnyDate

AnyDate can parse date strings without knowing format in advance.

This library is a ~~fairly incomplete port of~~ *based on* Go's [dateparse](https://github.com/araddon/dateparse):

> dateparse parses date-strings without knowing the format in advance, using a fast lex based approach to eliminate shotgun attempts. It leans towards US style dates when there is a conflict.

**MM/DD/YYYY vs DD/MM/YYYY**: By default, the parser uses *mm/dd/yyyy* when ambiguous. You can customize this behavior with the `AnyDateParser.preferMonthFirst` property, which, if unset, will use mm/dd);

```swift
var parser = AnyDateParser()
parser.locale = Locale(identifier: "en_GB")

// mm/dd date parsing
try parser.parse(string: "3/1/2014").date()

// dd/mm date parsing
parser.preferMonthFirst = false
try parser.parse(string: "3/1/2014").date()

// format parsing
let result = try parser.parse(string: "May 8, 2009 5:57:51 PM")
print(result.dateFormat)
> "MMM d, yyyy h:mm:ss a"
```
## To-Do
 
- [ ] Implement *reference layout* to *date format* conversion
- [ ] Fix unsupported components (e.g. "UTC-05", "UTC+0100", "GMT-0700", "CEST", "+00:00 "...)
- [ ] Use `isAmbiguous` and `preferMonthFirst` in dates that use slashes
- [ ] Fix AM/PM parsing (e.g. "04/02/2014 04:08:09.123 PM")
- [ ] Localize days of the week, ordinals, etc.
- [ ] Add `preferredMMDD` property to `Locale` instances
- [ ] Parse ambiguous short formats (e.g. MSK) independently of the locale's "cu" (commonly used) flag

## Links

- <http://www.openradar.me/9944011>
- <http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns>
- <http://userguide.icu-project.org/formatparse/datetime>

## Alternatives

- [when](https://github.com/quire-io/SwiftyChrono)
- [SwiftyChrono](https://github.com/quire-io/SwiftyChrono)
- [MKDataDetector](https://github.com/mayankk2308/mkdatadetector)
- [NSDataDetector](https://developer.apple.com/documentation/foundation/nsdatadetector)
