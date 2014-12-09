/*
* Copyright (c) 2014 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import Foundation

public class BitCoinStats : NSObject, NSCoding, Printable {
    let marketPriceUSD: NSNumber
    let time: NSDate
    override public var description: String {
        return "Price: \(marketPriceUSD) right now (\(time))"
    }
    
    public init(fromJSON json: JSONValue) {
        marketPriceUSD = json["market_price_usd"].number!
        
        let timeInterval :NSTimeInterval = json["timestamp"].double! / 1000
        time = NSDate(timeIntervalSince1970: timeInterval)
        
    }
    
    public required init(coder aDecoder: NSCoder) {
        marketPriceUSD = aDecoder.decodeObjectForKey("marketPriceUSD") as NSNumber
        time = aDecoder.decodeObjectForKey("time") as NSDate
    }
    
    public func encodeWithCoder(aCoder: NSCoder)  {
        aCoder.encodeObject(marketPriceUSD, forKey: "marketPriceUSD")
        aCoder.encodeObject(time, forKey: "time")
    }
}