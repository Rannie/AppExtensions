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
import CryptoCurrencyKit

class ViewController: CurrencyDataViewController {
  
  @IBOutlet var priceOnDayLabel: UILabel!
  
  let dateFormatter: NSDateFormatter
  
  required init(coder aDecoder: NSCoder) {
    dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "EEE M/d"
    
    super.init(coder: aDecoder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    lineChartView.dataSource = self
    lineChartView.delegate = self
    
    priceOnDayLabel.text = ""
    dayLabel.text = ""
  }
  
  override func viewWillAppear(animated: Bool)  {
    super.viewWillAppear(animated)
    
    fetchPrices{ error in
      if error == nil {
        self.updatePriceLabel()
        self.updatePriceChangeLabel()
        self.updatePriceHistoryLineChart()
      }
    }
  }
  
  override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    coordinator.animateAlongsideTransition(nil) { _ in
      self.lineChartView.reloadData()
    }
  }
  
  func updatePriceOnDayLabel(price: BitCoinPrice) {
    priceOnDayLabel.text = dollarNumberFormatter.stringFromNumber(price.value)
  }
  
  func updateDayLabel(price: BitCoinPrice) {
    dayLabel.text = dateFormatter.stringFromDate(price.time)
  }
  
  // MARK: - JBLineChartViewDataSource & JBLineChartViewDelegate
  
  func lineChartView(lineChartView: JBLineChartView!, didSelectLineAtIndex lineIndex: UInt, horizontalIndex: UInt) {
    if let prices = prices {
      let price = prices[Int(horizontalIndex)]
      updatePriceOnDayLabel(price)
      updateDayLabel(price)
    }
  }
  
  func didUnselectLineInLineChartView(lineChartView: JBLineChartView!) {
    priceOnDayLabel.text = ""
    dayLabel.text = ""
  }
  
}

