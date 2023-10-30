

import UIKit

class WJQRView: UIView {
    private var timer:Timer!
    private var distance:Int!
    private var corner1:UIImageView = {
        let corner = UIImageView()
        corner.contentMode = UIView.ContentMode.scaleAspectFill
        return corner
    }()
    
    private var corner2:UIImageView = {
        let corner = UIImageView()
        corner.contentMode = UIView.ContentMode.scaleAspectFill
        return corner
    }()
    
    private var corner3:UIImageView = {
        let corner = UIImageView()
        corner.contentMode = UIView.ContentMode.scaleAspectFill
        return corner
    }()
    
    private var corner4:UIImageView = {
        let corner = UIImageView()
        corner.contentMode = UIView.ContentMode.scaleAspectFill
        return corner
    }()
    
    private var maskImageView:UIImageView = {
        let maskImageView = UIImageView()
        maskImageView.contentMode = UIView.ContentMode.scaleToFill
        return maskImageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    func setUpView() {
        layer.masksToBounds = true
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 0.5

        addSubview(corner1)
        addSubview(corner2)
        addSubview(corner3)
        addSubview(corner4)
        layoutCornersViews()
        addSubview(maskImageView)
        loadMaskImage()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layoutCornersViews() {
        corner1.image = UIImage(named:"scan_one")
        corner2.image = UIImage(named:"scan_two")
        corner3.image = UIImage(named:"scan_three")
        corner4.image = UIImage(named:"scan_four")

        if let size = corner1.image?.size {
            corner1.frame = CGRect(origin: CGPoint.zero, size:size)
        }
        if let size = corner2.image?.size {
            corner2.frame = CGRect(origin: CGPoint(x: bounds.width - size.width, y: 0) , size:size)
        }
        if let size = corner3.image?.size {
            corner3.frame = CGRect(origin: CGPoint(x: 0, y: bounds.height - size.height), size:size)
        }
        if let size = corner4.image?.size {
            corner4.frame = CGRect(origin: CGPoint(x: bounds.width - size.width, y: bounds.height - size.height), size:size)
        }
    }
    
    private func loadMaskImage() {
        maskImageView.image = UIImage(named: "line")
        if let size = maskImageView.image?.size {
            let height = min(self.bounds.height, size.height)
            maskImageView.frame = CGRect(origin: CGPoint(x: 0, y: -height), size:CGSize(width: bounds.width, height:2))
        }
    }
    
    func startAnimation() {
        distance = 0
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .common)
    }
    
    @objc func timerAction(){
        distance! += 1
        if distance>260 {
            distance = 0
        }else {
            maskImageView.frame = CGRect(origin: CGPoint(x: 0, y: distance), size: CGSize(width:260, height: 2))
        }
        
    }
    func stopAnimation() {
        guard let timer1 = self.timer
            else{ return }
        timer1.invalidate()
        timer = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}





































































