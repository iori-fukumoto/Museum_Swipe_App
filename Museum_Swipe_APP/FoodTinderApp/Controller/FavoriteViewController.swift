//
//  FavoriteViewController.swift
//  FoodTinderApp
//
//  Created by 福本伊織 on 2021/03/19.
//

import UIKit
import Firebase
import SDWebImage
import PKHUD
import EMAlertController



class FavoriteViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    

    var userID = String()
    var userName = String()
    var dataModelArray = [DataModel]()
    var autoIDArray = [String]()
    
   
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var logout: UIButton!
    
    
    //初期化
    var favRef = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        logout.layer.cornerRadius = 20.0
        
        if UserDefaults.standard.object(forKey: "userID") != nil {
            
            userID = UserDefaults.standard.object(forKey: "userID") as! String
            
        }
        if UserDefaults.standard.object(forKey: "userName") != nil{
            
            userName = UserDefaults.standard.object(forKey: "userName") as! String
            //NavigationBarのタイトルの部分。（NabigationControllerを継承しているから使える）
            self.title = "\(userName)'s ArtWork List"
        }
        
       
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        self.title = "\(userName)'s ArtWork List"
        //ナビゲーションコントローラーの色を指定する
        self.navigationController?.navigationBar.tintColor = .white
        //ナビゲーションバーを表示する（隠さない）
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    
    
    
    
    
    
    
    
    //ref = Database.database().reference().child("users").child(userID).childByAutoId()　のuserID以下を取得する。
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //インディケーター回す
        HUD.show(.progress)
        //userID以下を取得する
        favRef.child("users").child(userID).observe(.value) { (snapShot) in
            
            //配列を空にする
            self.dataModelArray.removeAll()
            
            //オートIDの数データを取得していく
            for child in snapShot.children{
                
                //オートIDをひとつずつDataSnapshot型に変換
                let childSnapshot = child as! DataSnapshot
                //インスタンス化＆値を入れる
                let data = DataModel(snapshot: childSnapshot)
                
          //      print(childSnapshot.key)
                
                //MusicDataModelのプロパティの値を配列に入れていく
                self.dataModelArray.insert(data, at: 0)
                self.autoIDArray.insert(childSnapshot.key, at: 0)
                
                self.collectionView.reloadData()
                
            }
            
            HUD.hide()
        }
        
    }
    
    
    
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataModelArray.count
    }
    
    
    
    
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        let musicDataModel = dataModelArray[indexPath.row]
        
        let imageView = cell.contentView.viewWithTag(1) as! UIImageView
        imageView.sd_setImage(with: URL(string: musicDataModel.primaryImage),placeholderImage: UIImage(named: "progress"),options: .continueInBackground,context: nil,progress: nil, completed: nil)
        
        return cell
    }
    
    
    
    
    
    
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //画像をタップされたら画面遷移、配列の値を渡す。VC.名前 = 配列名[indexPath.row].名前
        let detailVC = self.storyboard?.instantiateViewController(identifier: "detailVC") as! DatailViewController
        
        detailVC.imageString = dataModelArray[indexPath.row].primaryImage
        detailVC.artistDisplayNameString = dataModelArray[indexPath.row].artistDisplayName
        detailVC.titleString = dataModelArray[indexPath.row].title
        detailVC.objectDateString = dataModelArray[indexPath.row].objectDate
        detailVC.userID = userID
        detailVC.userName = userName
        detailVC.autoID = autoIDArray[indexPath.row]
        
        self.navigationController?.pushViewController(detailVC, animated: true)
        
    }
    
    
    
    
    
    @IBAction func logout(_ sender: Any) {
        
        
        //アラート
        let alert = EMAlertController(icon: UIImage(named: "!!"), title: "Yes or Cancel", message: "ログアウトしますか？")
        let cancel = EMAlertAction(title: "CANCEL", style: .cancel)
        let confirm = EMAlertAction(title: "OK", style: .normal) {
            
            //OKならログアウト
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
                
            } catch let error as NSError {
                print("エラー",error)
            }
            
            self.navigationController?.popToRootViewController(animated: true)
            
        }
        
        alert.addAction(cancel)
        alert.addAction(confirm)
        present(alert, animated: true, completion: nil)
        
    }
    
    
    
    
    
    //3分割に。
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //幅を三分割にしている。
        let width = collectionView.bounds.width/3.0
        let height = width
        
        return CGSize(width: width, height: height)
    }
    
    
    
    
    
    
    //以下は意味をなさない。
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
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
