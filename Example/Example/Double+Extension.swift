//
//  Double+Extension.swift
//  GDGK_iOSExam
//
//  Created by cleven on 23.4.21.
//

extension Double {
    /// 小数点后如果只是0，显示整数，如果不是，显示原来的值
    var cleanZero : String {
        let numberString = "\(self)"
        if numberString.count > 1 {
            let strs = numberString.components(separatedBy: ".")
            let last = Int(strs.last ?? "0") ?? 0
            if strs.count == 2 {
                if last > 0 {
                    return String(format: "%.2f", self)
                }else{
                    return "\(Int(self))"
                }
            }
            return numberString
        }else{
            return "\(self)"
        }
    }
}
