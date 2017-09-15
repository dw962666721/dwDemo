//
//  dwMarkerView.swift
//  ChartsDemo
//
//  Created by mac on 2017/9/14.
//  Copyright © 2017年 dcg. All rights reserved.
//

import Foundation
import Charts

open class dwMarkerView: MarkerView
{
    open var label:UILabel?;
    public override init(frame: CGRect)
    {
        super.init(frame: frame);
        self.frame = CGRect(x: 0, y: 0, width: 50, height: 10);
        self.offset.y = -5.0
        //        label = UILabel();
        //        label?.backgroundColor = UIColor.lightGray;
        //        label?.textColor=UIColor.white;
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    open override func awakeFromNib()
    {
        //        self.offset.x = -self.frame.size.width / 2.0
        //        self.offset.y = -self.frame.size.height - 7.0
    }
    
    open override func refreshContent(entry: ChartDataEntry, highlight: Highlight)
    {
        //        label?.text = String.init(format: "%d %%", Int(round(entry.y)))
        //        layoutIfNeeded()
    }
    open override func offsetForDrawing(atPoint point: CGPoint) -> CGPoint {
        var offset = self.offset
        
        let chart = self.chartView
        
        let width = self.bounds.size.width
        let height = self.bounds.size.height
        
                if point.x + offset.x < 0.0
                {
                    offset.x = -point.x
                }
                else if chart != nil && point.x + width + offset.x > chart!.bounds.size.width
                {
                    offset.x = chart!.bounds.size.width - point.x - width
                }
        offset.x = chart!.bounds.size.width - point.x - self.chartView!.xAxis.labelWidth/2
        if point.y + offset.y < 0
        {
            offset.y = -point.y
        }
        else if chart != nil && point.y + height + offset.y > chart!.bounds.size.height
        {
            offset.y = chart!.bounds.size.height - point.y - height
        }
        
        return offset
        
    }
//    open override func draw(context: CGContext, point: CGPoint)
//    {
////        let offset = self.offsetForDrawing(atPoint: point)
//        super.draw(context: context, point:CGPoint(x:self.chartView!.bounds.size.width - self.chartView!.xAxis.labelWidth+self.chartView!.xAxis.labelWidth/2, y: point.y + self.offset.y));
////        super.draw(context: context, point:CGPoint(x:point.x, y: point.y + self.offset.y));
//
//    }
}
