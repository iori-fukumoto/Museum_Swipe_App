//
//  CardTableViewCell.swift
//  FoodTinderApp
//
//  Created by 福本伊織 on 2021/03/17.
//

import UIKit
import VerticalCardSwiper

class CardTableViewCell: CardCell {
    
    
    @IBOutlet weak var primaryImageView: UIImageView!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    
    //スワイプするごとにランダムでセルの背景色を変えられる。ライブラリに書いてある通りに記述
    public func setRandomBackgroundColor() {
        
        let randomRed: CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let randomGreen: CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let randomBlue: CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
        self.backgroundColor = UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
    
    
    //カードの角丸具合
    override func layoutSubviews() {
        self.layer.cornerRadius = 12
        super.layoutSubviews()
    }
    
    
}
