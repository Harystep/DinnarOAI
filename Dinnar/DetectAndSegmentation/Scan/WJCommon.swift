

import UIKit

class WJCommon: NSObject {
    // MARK:- 打开系统设置
   static func canOpenSystemSetting() -> Bool {
        if #available(iOS 8.0, *) {
            let settingUrl = NSURL(string: UIApplication.openSettingsURLString)!
            if UIApplication.shared.canOpenURL(settingUrl as URL)
            {
                return true
            }else {
                return false
            }
        }
        return false
    }
    
}
