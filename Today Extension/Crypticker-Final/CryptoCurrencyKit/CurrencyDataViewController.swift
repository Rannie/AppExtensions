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

import UIKit

public class CurrencyDataViewController: UIViewController, JBLineChartViewDataSource, JBLineChartViewDelegate {
  
  @IBOutlet public var priceLabel: UILabel!
  @IBOutlet public var priceChangeLabel: UILabel!
  @IBOutlet public var dayLabel: UILabel!
  @IBOutlet public var lineChartView: JBLineChartView!
  
  public let dollarNumberFormatter: NSNumberFormatter, prefixedDollarNumberFormatter: NSNumberFormatter
  
  public var prices: [BitCoinPrice]?
  public var priceDifference: NSNumber? {
    get {
      var difference: NSNumber?
      if (stats != nil && prices != nil) {
        if let yesterdaysPrice = BitCoinService.sharedInstance.yesterdaysPriceUsingPriceHistory(prices!) {
          difference = NSNumber(float: stats!.marketPriceUSD.floatValue - yesterdaysPrice.value.floatValue)
        }
      }
      
      return difference
    }
  }
  
  public var stats: BitCoinStats?
  
  public required init(coder aDecoder: NSCoder) {
    dollarNumberFormatter = NSNumberFormatter()
    dollarNumberFormatter.numberStyle = .CurrencyStyle
    dollarNumberFormatter.positivePrefix = ""
    dollarNumberFormatter.negativePrefix = ""
    
    prefixedDollarNumberFormatter = NSNumberFormatter()
    prefixedDollarNumberFormatter.numberStyle = .CurrencyStyle
    prefixedDollarNumberFormatter.positivePrefix = "+"
    prefixedDollarNumberFormatter.negativePrefix = "-"
    
    super.init(coder: aDecoder)
  }
  
  public func fetchPrices(completion: (error: NSError?) -> ()) {
    BitCoinService.sharedInstance.getStats { stats, error in
      BitCoinService.sharedInstance.getMarketPriceInUSDForPast30Days { prices, error in
        dispatch_async(dispatch_get_main_queue()) {
          self.prices = prices
          self.stats = stats
          completion(error: error)
        }
      }
    }
  }
  
  public func updatePriceLabel() {
    self.priceLabel.text =  priceLabelString()
  }
  
  public func updatePriceChangeLabel() {
    let stringAndColor = priceChangeLabelStringAndColor()
    priceChangeLabel.textColor = stringAndColor.color
    priceChangeLabel.text = stringAndColor.string
  }
  
  public func updatePriceHistoryLineChart() {
    if let prices = prices {
      let pricesNSArray = prices as NSArray
      let maxPrice = pricesNSArray.valueForKeyPath("@max.value") as NSNumber
      lineChartView.maximumValue = CGFloat(maxPrice.floatValue * 1.02)
      lineChartView.reloadData()
    }
  }
  
  public func priceLabelString() -> (String) {
    return dollarNumberFormatter.stringFromNumber(stats?.marketPriceUSD ?? 0) ?? "0"
  }
  
  public func priceChangeLabelStringAndColor() -> (string: String, color: UIColor) {
    var string: String?
    var color: UIColor?
    
    if let priceDifference = priceDifference {
      if (priceDifference.floatValue > 0) {
        color = UIColor.greenColor()
      } else {
        color = UIColor.redColor()
      }
      
      string = prefixedDollarNumberFormatter.stringFromNumber(priceDifference)
    }
    
    return (string ?? "", color ?? UIColor.blueColor())
  }
  
  // MARK: - JBLineChartViewDataSource & JBLineChartViewDelegate
  
  public func numberOfLinesInLineChartView(lineChartView: JBLineChartView!) -> UInt {
    return 1
  }
  
  public func lineChartView(lineChartView: JBLineChartView!, numberOfVerticalValuesAtLineIndex lineIndex: UInt) -> UInt {
    var numberOfValues = 0
    if let prices = prices {
      numberOfValues = prices.count
    }
    
    return UInt(numberOfValues)
  }
  
  public func lineChartView(lineChartView: JBLineChartView!, verticalValueForHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> CGFloat {
    var value: CGFloat = 0.0
    if let prices = prices {
      let price = prices[Int(horizontalIndex)]
      value = CGFloat(price.value.floatValue)
    }
    
    return value
  }
  
  public func lineChartView(lineChartView: JBLineChartView!, widthForLineAtLineIndex lineIndex: UInt) -> CGFloat {
    return 2.0
  }
  
  public func lineChartView(lineChartView: JBLineChartView!, colorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
    return UIColor.whiteColor()
  }
  
  public func verticalSelectionWidthForLineChartView(lineChartView: JBLineChartView!) -> CGFloat {
    return 1.0;
  }
  
}
