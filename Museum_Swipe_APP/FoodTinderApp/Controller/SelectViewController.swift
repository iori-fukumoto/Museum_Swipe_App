//
//  SelectViewViewController.swift
//  FoodTinderApp
//
//  Created by 福本伊織 on 2021/03/17.
//

import UIKit
import VerticalCardSwiper //Tinder風に.TableViewと使い方が似ている。
import SDWebImage  //DBから画像のurlをとってきてimageviewに表示するためのキャッシュを取れるもの
import PKHUD  //くるくる
import Firebase //右にスワイプしたときにDBへ


class SelectViewController: UIViewController,VerticalCardSwiperDelegate,VerticalCardSwiperDatasource  {
    
    

    //値を受け取る用
    var artistDisplayNameArray = [String]()
    var primaryImageArray = [String]()
   // var primaryImageSmallArray = [String]()
    var titleArray = [String]()
    var objectDateArray = [String]()
    var userID = String()
    var userName = String()
    
    //以下受取り用とはまた別の箱
    var indexNumber = Int()
    
    //お気に入り用
    var likeArtistDisplayNameArray = [String]()
    var likePrimaryImageArray = [String]()
    var likeTitleArray = [String]()
    var likeObjectDateArray = [String]()
    

    @IBOutlet weak var cardSwiper: VerticalCardSwiper!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        cardSwiper.delegate = self
        cardSwiper.datasource = self
        
        //カスタムセルの登録
        cardSwiper.register(nib:UINib(nibName: "CardTableViewCell", bundle: nil), forCellWithReuseIdentifier: "CardViewCell")
        
        //reloadData()をすることでnumberOfCards,cardForItemAtが呼ばれる
        cardSwiper.reloadData()

        
        // Do any additional setup after loading the view.
    }
    
    
    
    
    
    
    func numberOfCards(verticalCardSwiperView: VerticalCardSwiperView) -> Int {
        return titleArray.count
    }
    
    
    
    
    func cardForItemAt(verticalCardSwiperView: VerticalCardSwiperView, cardForItemAt index: Int) -> CardCell {
        
        //CardViewCellがあるかどうかの確認。（if文ではない）あるならセルの中に入れる。
        if let cardCell = verticalCardSwiperView.dequeueReusableCell(withReuseIdentifier: "CardViewCell", for: index) as? CardTableViewCell{
            
            //カードの後ろもランダムで色を変える
            verticalCardSwiperView.backgroundColor = UIColor.black
            view.backgroundColor = verticalCardSwiperView.backgroundColor
            
            
            //セル（カード）に配列を表示させる
            let artistDisplayName = artistDisplayNameArray[index]
            let title = titleArray[index]
            let objectDate = objectDateArray[index]
            
            cardCell.setRandomBackgroundColor()
            
            cardCell.artistNameLabel.text = artistDisplayName
            cardCell.artistNameLabel.textColor = UIColor.white
            cardCell.titleLabel.text = title
            cardCell.titleLabel.textColor = UIColor.white
            cardCell.dateLabel.text = objectDate
            cardCell.dateLabel.textColor = UIColor.white
            
         
            //セル（カード）の画像表示。imageViewにURLを貼っていく
            cardCell.primaryImageView.sd_setImage(with: URL(string: primaryImageArray[index]),placeholderImage: UIImage(named: "progress"), completed: nil)
            cardCell.primaryImageView.image?.jpegData(compressionQuality: 0.01)
            
            
            return cardCell
            
        }
        //カードセルがない場合も空のカードセルを返す
        return CardCell()
        
    }

    
    
    
    
    
    
    //スワイプしたときに配列の中を消さないといけない。値が残ったままだとインデックスが崩れるから。このコードがない場合とある場合で何が違うのか、配列の中身の数を追って確かめてください、とのこと。
    func willSwipeCardAway(card: CardCell, index: Int, swipeDirection: SwipeDirection) {
        
        indexNumber = index
        
        if swipeDirection == .Right {
            
            likeArtistDisplayNameArray.append(artistDisplayNameArray[indexNumber])
            
            likePrimaryImageArray.append(primaryImageArray[indexNumber])
            
            likeTitleArray.append(titleArray[indexNumber])
            
            likeObjectDateArray.append(objectDateArray[indexNumber])
            
            if likeArtistDisplayNameArray.count != 0 && likePrimaryImageArray.count != 0 && likeTitleArray.count != 0 && likeObjectDateArray.count != 0 {
                
             /*   let musicDataModel = MusicDataModel(artistName: artistNameArray[indexNumber], musicName: musicNameArray[indexNumber], preViewURL: previewURLArray[indexNumber], imageString: imageStringArray[indexNumber], userID: userID, userName: userName)*/
                let dataModel = DataModel(artistDisplayName: artistDisplayNameArray[indexNumber], primaryImage: primaryImageArray[indexNumber], title: titleArray[indexNumber], objectDate: objectDateArray[indexNumber], userID: userID, userName: userName)
                
                dataModel.save()
                
            }
            
        }
        
        artistDisplayNameArray.remove(at: index)
        primaryImageArray.remove(at: index)
        titleArray.remove(at: index)
        objectDateArray.remove(at: index)
        
    }

    
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
