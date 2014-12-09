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

typealias StatsCompletionBlock = (stats: BitCoinStats?, error: NSError?) -> ()
typealias MarketPriceCompletionBlock = (prices: [BitCoinPrice]?, error: NSError?) -> ()

class BitCoinService {
  
  let statsCacheKey = "BitCoinServiceStatsCache"
  let statsCachedDateKey = "BitCoinServiceStatsCachedDate"
  
  let priceHistoryCacheKey = "BitCoinServicePriceHistoryCache"
  let priceHistoryCachedDateKey = "BitCoinServicePriceHistoryCachedDate"
  
  let session: NSURLSession
  
  class var sharedInstance: BitCoinService {
    struct Singleton {
      static let instance = BitCoinService()
    }
    return Singleton.instance
  }
  
  init() {
    let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
    session = NSURLSession(configuration: configuration)
  }
  
  func getStats(completion: StatsCompletionBlock) {
    if let cachedStats: BitCoinStats = getCachedStats() {
      completion(stats: cachedStats, error: nil)
      return
    }
    
    let statsUrl = NSURL(string: "https://blockchain.info/stats?format=json")!
    let request = NSURLRequest(URL: statsUrl)
    let task = session.dataTaskWithRequest(request) {[unowned self] data, response, error in
      if error == nil {
        var jsonError: NSError?
        if (jsonError == nil) {
          let statsDictionary = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.AllowFragments, error: &jsonError) as NSDictionary
          let stats: BitCoinStats = BitCoinStats(fromJSON: JSONValue(statsDictionary))
          self.cacheStats(stats)
          completion(stats: stats, error: nil)
        } else {
          completion(stats: nil, error: jsonError)
        }
      } else {
        completion(stats: nil, error: error)
      }
    }
    
    task.resume()
  }
  
  func getMarketPriceInUSDForPast30Days(completion: MarketPriceCompletionBlock) {
    if let cachedPrices: [BitCoinPrice] = getCachedPriceHistory() {
      completion(prices: cachedPrices, error: nil)
      return
    }
    
    let pricesUrl = NSURL(string: "https://blockchain.info/charts/market-price?timespan=30days&format=json")!
    let request = NSURLRequest(URL: pricesUrl);
    let task = session.dataTaskWithRequest(request) {[unowned self] data, response, error in
      if error == nil {
        var jsonError: NSError?
        let pricesDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &jsonError) as NSDictionary
        if (jsonError == nil) {
          let json = JSONValue(pricesDictionary)
          let priceValues = pricesDictionary["values"] as Array<NSDictionary>
          var prices = [BitCoinPrice]()
          for priceDictionary in priceValues {
            let price = BitCoinPrice(fromJSON: JSONValue(priceDictionary))
            prices.append(price)
          }
          self.cachePriceHistory(prices)
          completion(prices: prices, error: nil)
          
        } else {
          completion(prices: nil, error: jsonError)
        }
        
      } else {
        completion(prices: nil, error: error)
      }
    }
    
    task.resume()
  }
  
  func yesterdaysPriceUsingPriceHistory(priceHistory: Array<BitCoinPrice>) -> (BitCoinPrice?) {
    var yesterdaysPrice: BitCoinPrice?
    
    for price in priceHistory.reverse() {
      if (price.time.isYesterday()) {
        yesterdaysPrice = price
        break;
      }
    }
    
    return yesterdaysPrice
  }
  
  
  func loadCachedDataForKey(key: String, cachedDateKey: String) -> AnyObject? {
    var cachedValue: AnyObject?
    
    if let cachedDate = NSUserDefaults.standardUserDefaults().valueForKey(cachedDateKey) as? NSDate {
      let timeInterval = NSDate().timeIntervalSinceDate(cachedDate)
      if (timeInterval < 60*5) {
        let cachedData = NSUserDefaults.standardUserDefaults().valueForKey(key) as? NSData
        if cachedData != nil {
          cachedValue = NSKeyedUnarchiver.unarchiveObjectWithData(cachedData!)
        }
      }
    }
    
    
    return cachedValue
  }
  
  func getCachedStats() -> BitCoinStats? {
    let stats = loadCachedDataForKey(statsCacheKey, cachedDateKey: statsCachedDateKey) as? BitCoinStats
    return stats
  }
  
  func getCachedPriceHistory() -> [BitCoinPrice]? {
    let prices = loadCachedDataForKey(priceHistoryCacheKey, cachedDateKey: priceHistoryCachedDateKey) as? [BitCoinPrice]
    return prices
  }
  
  func cacheStats(stats: BitCoinStats) {
    print(stats)
    let statsData = NSKeyedArchiver.archivedDataWithRootObject(stats)
    
    NSUserDefaults.standardUserDefaults().setValue(statsData, forKey: statsCacheKey)
    NSUserDefaults.standardUserDefaults().setValue(NSDate(), forKey: statsCachedDateKey)
  }
  
  func cachePriceHistory(history: [BitCoinPrice]) {
    let priceData = NSKeyedArchiver.archivedDataWithRootObject(history)
    
    NSUserDefaults.standardUserDefaults().setValue(priceData, forKey: priceHistoryCacheKey)
    NSUserDefaults.standardUserDefaults().setValue(NSDate(), forKey: priceHistoryCachedDateKey)
  }
}

