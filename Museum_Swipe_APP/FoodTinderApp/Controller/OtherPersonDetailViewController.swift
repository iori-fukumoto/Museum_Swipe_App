//
//  OtherPersonDetailViewController.swift
//  FoodTinderApp
//
//  Created by 福本伊織 on 2021/03/20.
//

import UIKit
import SDWebImage
import EMAlertController

class OtherPersonDetailViewController: UIViewController {
    
    var userID = String()
    var userName = String()
    var imageString = String()
    var artistDisplayNameString = String()
    var titleString = String()
    var objectDateString = String()
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var objectDateLabel: UILabel!
    
    @IBOutlet weak var saveButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        saveButton.layer.cornerRadius = 25.0
        
        //アプリ内に保存したuserID,userNameを取得
        if UserDefaults.standard.object(forKey: "userID") != nil {
            
            userID = UserDefaults.standard.object(forKey: "userID") as! String
            
        }
        
        if UserDefaults.standard.object(forKey: "userName") != nil{
            
            userName = UserDefaults.standard.object(forKey: "userName") as! String
        }
        
        
        
        //渡ってきた値を入れていく
        imageView.sd_setImage(with: URL(string: imageString),placeholderImage: UIImage(named: "progress"),completed: nil)
        titleLabel.text = titleString
        artistNameLabel.text = artistDisplayNameString
        objectDateLabel.text = objectDateString
        
        
      
        
       
        
        // Do any additional setup after loading the view.
    }
    
    
    
    
    
    /* override func viewWillAppear(_ animated: Bool) {
     super.viewWillAppear(animated)
     
     self.navigationController?.isNavigationBarHidden = true
     }*/
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    
    @IBAction func SaveToMyList(_ sender: Any) {
        
        
       let dataModel = DataModel(artistDisplayName: artistDisplayNameString, primaryImage: imageString, title: titleString, objectDate: objectDateString, userID: userID, userName: userName)
            
        dataModel.save()
        
        //アラート
        let alert = EMAlertController(icon: UIImage(named: "check"), title: "追加完了！", message: "マイリストを見てみよう！")
        let doneAction = EMAlertAction(title: "OK", style: .normal)
        alert.addAction(doneAction)
        present(alert, animated: true, completion: nil)

        
        
    }
    
    
    
    
    
    
    
  /*  if swipeDirection == .Right {
        
        likeArtistDisplayNameArray.append(artistDisplayNameArray[indexNumber])
        
        likePrimaryImageArray.append(primaryImageArray[indexNumber])
        
        likeTitleArray.append(titleArray[indexNumber])
        
        likeObjectDateArray.append(objectDateArray[indexNumber])
        
        if likeArtistDisplayNameArray.count != 0 && likePrimaryImageArray.count != 0 && likeTitleArray.count != 0 && likeObjectDateArray.count != 0 {
            
            let musicDataModel = MusicDataModel(artistDisplayName: artistDisplayNameArray[indexNumber], primaryImage: primaryImageArray[indexNumber], title: titleArray[indexNumber], objectDate: objectDateArray[indexNumber], userID: userID, userName: userName)
            
            musicDataModel.save()
            
        }
        
    }
    
    artistDisplayNameArray.remove(at: index)
    primaryImageArray.remove(at: index)
    titleArray.remove(at: index)
    objectDateArray.remove(at: index)
    
}*/

    
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

