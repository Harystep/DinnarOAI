//
//  DateTool.swift
//  Dinnar
//
//  Created by Lizheng Pang on 2023/6/25.
//

import Foundation
class DateTool {
    static func dateToStr(date:Date) -> String{
        let dformatter = DateFormatter()
        dformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let datestr = dformatter.string(from: date)
        return datestr
    }
    static func dayStartAndEnd(date:Date) -> (startTime:String,endTime:String){
        let dformatter = DateFormatter()
        dformatter.timeZone = TimeZone.init(secondsFromGMT: 3600*8)
        dformatter.dateFormat = "yyyy-MM-dd 00:00:00"
        let start = dformatter.string(from: date)
        dformatter.dateFormat = "yyyy-MM-dd 23:59:59"
        let end = dformatter.string(from: date)
        return (start,end)
    }
    static func monthStartAndEnd(date:Date) -> (startTime:String,endTime:String){
        let calendar = NSCalendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        
        let month = components.month
        let year = components.year
        let startDate = startOfMonth(year: year!, month: month!)
        let endDate = endOfMonth(year: year!, month: month!)
        let dformatter = DateFormatter()
        dformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let start = dformatter.string(from: startDate)
        let end = dformatter.string(from: endDate)
        return (start,end)
    }
    
    //指定年月的开始日期
    static func startOfMonth(year: Int, month: Int) -> Date {
        let calendar = NSCalendar.current
        var startComps = DateComponents()
        startComps.day = 1
        startComps.month = month
        startComps.year = year
        let startDate = calendar.date(from: startComps)!
        return startDate
    }
     
    //指定年月的结束日期
    static func endOfMonth(year: Int, month: Int, returnEndTime:Bool = true) -> Date {
        let calendar = NSCalendar.current
        var components = DateComponents()
        components.month = 1
        if returnEndTime {
            components.second = -1
        } else {
            components.day = -1
        }
         
        let endOfYear = calendar.date(byAdding: components,
                                      to: startOfMonth(year: year, month:month))!
        return endOfYear
    }

}
