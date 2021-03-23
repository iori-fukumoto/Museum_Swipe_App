//
//  SearchViewController.swift
//  TinderListApp
//
//  Created by 福本伊織 on 2021/03/09.
//

import UIKit
import PKHUD //通信中のくるくる
import Alamofire //通信を行う
import SwiftyJSON //Json解析を楽にする
import Firebase
import FirebaseAuth
import ChameleonFramework
import EMAlertController


class SearchViewController: UIViewController,UITextFieldDelegate {

    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var searchTextField: UITextField!
    //グラデーションをかけるためにつなげる
    @IBOutlet weak var favButton: UIButton!
    @IBOutlet weak var otherFavButton: UIButton!
    
    //配列を作る。AppleのJsonデータのキー値に合わせて配列をつくっている。
    var artistDisplayNameArray = [String]()
    var primaryImageArray = [String]()
  //  var primaryImageSmallArray = [String]()
    var titleArray = [String]()
    var objectDateArray = [String]()
    
    var count = Int()
    
    var userID = String()
    var userName = String()
    var autoID = String()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureSV()
        favButton.layer.cornerRadius = 20.0
        otherFavButton.layer.cornerRadius = 20.0
        
        //search画面にきた瞬間にキーボードを出してあげる
        searchTextField.delegate = self
        searchTextField.becomeFirstResponder()
        //ユーザーログインがまだの場合ログイン画面を表示
        //autoIDがあればそれを保存。
        if UserDefaults.standard.object(forKey: "autoID") != nil{
            
            autoID = UserDefaults.standard.object(forKey: "autoID") as! String
            print(autoID)
            
        }else{
            //autoIDがなければログイン画面を表示。
            //Main.storyboardをインスタンス化
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            //ログイン画面をインスタンス化。"LoginViewController"をログイン画面に設定。
            let loginVC = storyboard.instantiateViewController(identifier: "LoginVC")
            loginVC.modalPresentationStyle = .fullScreen
            present(loginVC, animated: true, completion: nil)
            
        }
        
        //autoIDと同じように,userID.userNameも保存
        if UserDefaults.standard.object(forKey: "userID") != nil &&  UserDefaults.standard.object(forKey: "userID") != nil{
            
            userID = UserDefaults.standard.object(forKey: "userID") as! String
            userName = UserDefaults.standard.object(forKey: "userName") as! String
            
        }
        
        //search画面にきた瞬間にキーボードを出してあげる
        searchTextField.delegate = self
        searchTextField.becomeFirstResponder()
        
       
        
        // Do any additional setup after loading the view.
    }
    
    
    
    
    
    
    //viewDidRoadの後に呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //ナビゲーションバーのBackButtonを消す
        //バーの色を設定
        self.navigationController?.navigationBar.standardAppearance.backgroundColor = UIColor.flatRed()
        self.navigationItem.setHidesBackButton(true, animated: true)
        
    }
    
    
    
    
    //キーボードを閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        //Searchを行う
        
        //下記はtextFieldのデリゲートが設定されているtextFieldを指す
        textField.resignFirstResponder()
        return true
        
    }
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        searchTextField.resignFirstResponder()
        
    }
    
    
    
    
    
    //カードスワイプ画面へ遷移
    @IBAction func moveToSelectCardView(_ sender: Any) {
        
        //パース（Json解析）を行ってから画面遷移
        startParse(keyword: searchTextField.text!)
       
    }
    
    
    

    
    
    //カード画面へ遷移メソッド
    func moveToCard(){
        
        performSegue(withIdentifier: "selectVC", sender: nil)
    }
    
    
    
      //遷移のときに値を渡す！これを書くだけで値がわたる！！
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //"selectVC"と記載してこの遷移で値を渡すことを明示
        if searchTextField.text! != nil && segue.identifier == "selectVC"{
           
            
            let selectVC = segue.destination as! SelectViewController
            selectVC.titleArray = self.titleArray
            selectVC.artistDisplayNameArray = self.artistDisplayNameArray
            selectVC.primaryImageArray = self.primaryImageArray
         //   selectVC.primaryImageSmallArray = self.primaryImageSmallArray
            selectVC.objectDateArray = self.objectDateArray
            selectVC.userID = self.userID
            selectVC.userName = self.userName
            
     
        }
    }
    
    

    //パース（Json解析）を行う
    func startParse(keyword: String){
        
        HUD.show(.progress) //PKHUD
        
        //配列を初期化。
        artistDisplayNameArray = [String]()
        primaryImageArray = [String]()
   //     primaryImageSmallArray = [String]()
        titleArray = [String]()
        objectDateArray = [String]()
        
        //どのURLで表示されているJsonファイルをパースするか。
        let urlString = "https://collectionapi.metmuseum.org/public/collection/v1/search?q=\(keyword)"
        //keywordをエンコードしてあげる
        let encodeUrlString:String = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        //Alamofireを使ってリクエストを投げる。
        AF.request(encodeUrlString, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON{ [self]
            (response)in
            
        //    print(response,"aaa")
            
            //Switch文でJsonのデータ(response)を取得する
            switch response.result{
            
            case .success:
                let json:JSON = JSON(response.data as Any)
                
                //"objectIDs"というデータが取得できる。
                //let objectIDs:Int = json["objectIDs"].int!
                let objectIDs = json["objectIDs"].map{ $0.1 }
            //    objectIDs.forEach{print($0.1)}
            
           //     print(objectIDs[1])
                
                
                if objectIDs.count == 0 || objectIDs.count == 1{
                    print("検索結果がありません。")
                    HUD.hide()
                    
                    //アラート
                    let alert = EMAlertController(icon: UIImage(named: "!!"), title: "検索結果がありません", message: "Please write english！")
                    let doneAction = EMAlertAction(title: "OK", style: .normal)
                    alert.addAction(doneAction)
                    present(alert, animated: true, completion: nil)
                    
                    return
                }
                
    //ーーーーーーーーーーーーーーーーーーーー以下ひとつずつIDを取り出して、配列に入れていくーーーーーーーーーーーーーーーーーーーー
                
                for i in 0 ..< objectIDs.count - 1 {
                    
                let urlString2 = "https://collectionapi.metmuseum.org/public/collection/v1/objects/\(objectIDs[i])"
                
                let encodeUrlString2:String = urlString2.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                
                AF.request(encodeUrlString2, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON{
                    (response2)in
                    
                 //入ってる   print(response2)
                    
                    //Switch文でJsonのデータ(response)を取得する
                    switch response2.result{
                    
                    case .success:
                        
                        let json2:JSON = JSON(response2.data as Any)
                        
                        //入ってる   print(json2)
                        let artistDisplayName = json2["artistDisplayName"].string
                        //"previewUrl"には再生する音源が入っているurlの在り処が入っている
                        let primaryImage = json2["primaryImageSmall"].string
                  //      let primaryImageSmall = json2["primaryImageSmall"].string
                        //アーティスト名
                        let title = json2["title"].string
                        //"trackCensoredName"は曲名が入っている
                        let objectDate = json2["objectDate"].string
                        
                        //[i]なしで入った print(title as Any,"ssssss")
                        
                        //配列に入れていく
                        self.artistDisplayNameArray.append(artistDisplayName!)
                        self.primaryImageArray.append(primaryImage!)
             //           self.primaryImageSmallArray.append(primaryImageSmall!)
                        self.titleArray.append(title!)
                        self.objectDateArray.append(objectDate!)
                
                  //      print(artistDisplayNameArray[i])
                        
                /*        if self.artistDisplayNameArray.count == objectIDs.count - 1 {
                            
                            
                            //データ取得と画面遷移が終わったらくるくるを閉じる
                            HUD.hide()
                            //カード画面へ遷移
                            self.moveToCard()
                            
                        }*/
                        
                        //検索結果が30以上なら30件を表示。それ未満なら全て表示。
                        if objectIDs.count - 1 >= 30{
                            
                            if self.artistDisplayNameArray.count == 30{
                                HUD.hide()
                                self.moveToCard()
                            }
                            
                        }else if objectIDs.count - 1 < 30 {
                            
                            if self.artistDisplayNameArray.count == objectIDs.count - 1{
                                
                                HUD.hide()
                                self.moveToCard()
                            }
                        }
                        
                        
                    case .failure(let error):
                        print(error)
                        
                        
                    }//switch文の締め。
                }//AFの締め
                }//for文の締め。
 
                
            //    print(ids[0],ids[1],ids[2])
            case .failure(let error):
                
                print(error)
                
            }
         
            
            
        }
        
    }
        
        

    
    
    
    //お気に入りボタンで遷移
    @IBAction func muveToFav(_ sender: Any) {
        
        let favVC = storyboard?.instantiateViewController(identifier: "fav") as! FavoriteViewController
        self.navigationController?.pushViewController(favVC, animated: true)
        
    }
    
    
    
    @IBAction func moveToMemberFav(_ sender: Any) {
        
        
        let menberFavVC = storyboard?.instantiateViewController(identifier: "menberFavVC") as! ListViewController
        self.navigationController?.pushViewController(menberFavVC, animated: true)
        
    }
    
    
    
    
    
    
  /*  let alert = EMAlertController(title: "EMAlertView Title", message: "This is a simple message for the EMAlertView")
     
     let cancel = EMAlertAction(title: "CANCEL", style: .cancel)
     let confirm = EMAlertAction(title: "CONFIRM", style: .normal) {
     // Perform Action
     }

     alert.addAction(cancel)
     alert.addAction(confirm)
}*/
    
    
    
    //--------------以下スクロールビュー------------------
    
    //ボタンを作るメソッド
    func createimage(contentsView: UIView,x:Double,y:Double,title:String,named:String) -> UIButton {
        
        let buttonImage = UIButton()
        
        buttonImage.frame = CGRect(x: x, y: y, width: 112, height: 112)
        buttonImage.setTitle(title, for:UIControl.State.normal)
        buttonImage.setTitleColor(UIColor.white, for: .normal)
        buttonImage.setBackgroundImage(UIImage(named: named), for: .normal)
        buttonImage.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        buttonImage.layer.cornerRadius = 56.0
        buttonImage.layer.masksToBounds = true
        
        return buttonImage
    }
    
    // labelを作る
    func createLabel(contentsView: UIView) -> UILabel {
        
        let label = UILabel()
        
        label.frame = CGRect(x: 69, y: 0, width: 276, height: 40)
        label.textAlignment = .center
        label.textColor = .gray
        
        label.text = "おすすめのアーティスト"
        return label
    }
    
    
    
    @objc func buttonTapped(sender : Any) {
        
        switch (sender as AnyObject).tag {
        case 1:
            startParse(keyword: "Gogh")
        case 2:
            startParse(keyword: "Joseph Mallord William Turner")
        case 3:
            startParse(keyword: "Odilon Redon")
        case 4:
            startParse(keyword: "Millet")
        case 5:
            startParse(keyword: "katsusika")
        case 6:
            startParse(keyword: "Henri Rousseau")
        case 7:
            startParse(keyword: "Paul Gauguin")
        case 8:
            startParse(keyword: "Paul Cézanne")
        case 9:
            startParse(keyword: "Vermeer")
        case 10:
            startParse(keyword: "Harnett")
        case 11:
            startParse(keyword: "Georges Seurat")
        case 12:
            startParse(keyword: "Camille Pissarro")
        case 13:
            startParse(keyword: "Renoir")
        case 14:
            startParse(keyword: "Courbet")
        case 15:
            startParse(keyword: "utagawa")
        case 16:
            startParse(keyword: "Corot")
        case 17:
            startParse(keyword: "manet")
        case 18:
            startParse(keyword: "Botticelli")
        case 19:
            startParse(keyword: "Leonardo da Vinci")
        case 20:
            startParse(keyword: "klimt")
        case 21:
            startParse(keyword: "Giuseppe Arcimboldo")
        case 22:
            startParse(keyword: "kano")
        case 23:
            startParse(keyword: "Lautrec")
        case 24:
            startParse(keyword: "Egon Schiele")
        case 25:
            startParse(keyword: "Hollar")
        case 26:
            startParse(keyword: "John Everett Millais")
        case 27:
            startParse(keyword: "Rembrandt")
        case 28:
            startParse(keyword: "Anna Atkins")
        case 29:
            startParse(keyword: "Bruegel")
        case 30:
            startParse(keyword: "Delacroix")
        case 31:
            startParse(keyword: "Chagall")
        case 32:
            startParse(keyword: "Pollock")
        case 33:
            startParse(keyword: "paul klee")
        case 34:
            startParse(keyword: "Matisse")
        case 35:
            startParse(keyword: "Kandinsky")
        case 36:
            startParse(keyword: "Picasso")
            
            
        default:
            print("error")
        }
    }
    
    
    
    func createContentsView() -> UIView {
        
        // contentsViewを作る
        let contentsView = UIView()
        contentsView.frame = CGRect(x: 0, y: 0, width: 414, height: 1700)
        
        let buttonImage = createimage(contentsView: contentsView, x: 19.5, y: 40, title: "Gugh", named: "1")
        buttonImage.tag = 1
        buttonImage.addTarget(self,
                              action: #selector(self.buttonTapped(sender:)),
                              for: .touchUpInside)
        contentsView.addSubview(buttonImage)
        
        let buttonImage2 = createimage(contentsView: contentsView, x: 151, y: 40, title: "Turner", named: "Joseph Mallord William Turner")
        buttonImage2.tag = 2
        buttonImage2.addTarget(self,
                               action: #selector(self.buttonTapped(sender:)),
                               for: .touchUpInside)
        contentsView.addSubview(buttonImage2)
        
        let buttonImage3 = createimage(contentsView: contentsView, x: 282.5, y: 40, title: "Redon", named: "Odilon Redon")
        buttonImage3.tag = 3
        buttonImage3.addTarget(self,
                               action: #selector(self.buttonTapped(sender:)),
                               for: .touchUpInside)
        contentsView.addSubview(buttonImage3)
        
        let buttonImage4 = createimage(contentsView: contentsView, x: 19.5, y: 171.5, title: "Millet", named: "Millet")
        buttonImage4.tag = 4
        buttonImage4.addTarget(self,
                               action: #selector(self.buttonTapped(sender:)),
                               for: .touchUpInside)
        contentsView.addSubview(buttonImage4)
        
        let buttonImage5 = createimage(contentsView: contentsView, x: 151, y: 171.5, title: "北斎", named: "katsushika")
        buttonImage5.tag = 5
        buttonImage5.addTarget(self,
                               action: #selector(self.buttonTapped(sender:)),
                               for: .touchUpInside)
        contentsView.addSubview(buttonImage5)
        
        let buttonImage6 = createimage(contentsView: contentsView, x: 282.5, y: 171.5, title: "Rousseau", named: "Rousseau")
        buttonImage6.tag = 6
        buttonImage6.addTarget(self,
                               action: #selector(self.buttonTapped(sender:)),
                               for: .touchUpInside)
        contentsView.addSubview(buttonImage6)
        
        let buttonImage7 = createimage(contentsView: contentsView, x: 19.5, y: 303, title: "Gauguin", named: "Gauguin")
        buttonImage7.tag = 7
        buttonImage7.addTarget(self,
                               action: #selector(self.buttonTapped(sender:)),
                               for: .touchUpInside)
        contentsView.addSubview(buttonImage7)
        
        let buttonImage8 = createimage(contentsView: contentsView, x: 151, y: 303, title: "Cézanne", named: "Cézanne")
        buttonImage8.tag = 8
        buttonImage8.addTarget(self,
                               action: #selector(self.buttonTapped(sender:)),
                               for: .touchUpInside)
        contentsView.addSubview(buttonImage8)
        
        let buttonImage9 = createimage(contentsView: contentsView, x: 282.5, y: 303, title: "Vermeer", named: "Vermeer")
        buttonImage9.tag = 9
        buttonImage9.addTarget(self,
                               action: #selector(self.buttonTapped(sender:)),
                               for: .touchUpInside)
        contentsView.addSubview(buttonImage9)
        
        let buttonImage10 = createimage(contentsView: contentsView, x: 19.5, y: 434.5, title: "Harnett", named: "Harnett")
        buttonImage10.tag = 10
        buttonImage10.addTarget(self,
                               action: #selector(self.buttonTapped(sender:)),
                               for: .touchUpInside)
        contentsView.addSubview(buttonImage10)
        
        let buttonImage11 = createimage(contentsView: contentsView, x: 151, y: 434.5, title: "Georges Seurat", named: "Georges Seurat")
        buttonImage11.tag = 11
        buttonImage11.addTarget(self,
                               action: #selector(self.buttonTapped(sender:)),
                               for: .touchUpInside)
        contentsView.addSubview(buttonImage11)
        
        let buttonImage12 = createimage(contentsView: contentsView, x: 282.5, y: 434.5, title: "Camille Pissarro", named: "Camille Pissarro")
        buttonImage12.tag = 12
        buttonImage12.addTarget(self,
                               action: #selector(self.buttonTapped(sender:)),
                               for: .touchUpInside)
        contentsView.addSubview(buttonImage12)
        
        let buttonImage13 = createimage(contentsView: contentsView, x: 19.5, y: 566, title: "Renoir", named: "Renoir")
        buttonImage13.tag = 13
        buttonImage13.addTarget(self,
                               action: #selector(self.buttonTapped(sender:)),
                               for: .touchUpInside)
        contentsView.addSubview(buttonImage13)
        
        let buttonImage14 = createimage(contentsView: contentsView, x: 151, y: 566, title: "Courbet", named: "Courbet")
        buttonImage14.tag = 14
        buttonImage14.addTarget(self,
                               action: #selector(self.buttonTapped(sender:)),
                               for: .touchUpInside)
        contentsView.addSubview(buttonImage14)
        
        let buttonImage15 = createimage(contentsView: contentsView, x: 282.5, y: 566, title: "Utagawa", named: "utagawa")
        buttonImage15.tag = 15
        buttonImage15.addTarget(self,
                               action: #selector(self.buttonTapped(sender:)),
                               for: .touchUpInside)
        contentsView.addSubview(buttonImage15)
        
        let buttonImage16 = createimage(contentsView: contentsView, x: 19.5, y: 697.5, title: "Corot", named: "Corot")
        buttonImage16.tag = 16
        buttonImage16.addTarget(self,
                               action: #selector(self.buttonTapped(sender:)),
                               for: .touchUpInside)
        contentsView.addSubview(buttonImage16)
        
        let buttonImage17 = createimage(contentsView: contentsView, x: 151, y: 697.5, title: "Manet", named: "manet")
        buttonImage17.tag = 17
        buttonImage17.addTarget(self,
                               action: #selector(self.buttonTapped(sender:)),
                               for: .touchUpInside)
        contentsView.addSubview(buttonImage17)
        
        let buttonImage18 = createimage(contentsView: contentsView, x: 282.5, y: 697.5, title: "Botticelli", named: "Botticelli")
        buttonImage18.tag = 18
        buttonImage18.addTarget(self,
                               action: #selector(self.buttonTapped(sender:)),
                               for: .touchUpInside)
        contentsView.addSubview(buttonImage18)
        
        let buttonImage19 = createimage(contentsView: contentsView, x: 19.5, y: 829, title: "Da Vinci", named: "Vinci")
        buttonImage19.tag = 19
        buttonImage19.addTarget(self,
                               action: #selector(self.buttonTapped(sender:)),
                               for: .touchUpInside)
        contentsView.addSubview(buttonImage19)
        
        let buttonImage20 = createimage(contentsView: contentsView, x: 151, y: 829, title: "Klimt", named: "klimt")
        buttonImage20.tag = 20
        buttonImage20.addTarget(self,
                               action: #selector(self.buttonTapped(sender:)),
                               for: .touchUpInside)
        contentsView.addSubview(buttonImage20)
        
        let buttonImage21 = createimage(contentsView: contentsView, x: 282.5, y: 829, title: "Arcimboldo", named: "Giuseppe Arcimboldo")
        buttonImage21.tag = 21
        buttonImage21.addTarget(self,
                               action: #selector(self.buttonTapped(sender:)),
                               for: .touchUpInside)
        contentsView.addSubview(buttonImage21)
        
        let buttonImage22 = createimage(contentsView: contentsView, x: 19.5, y: 960.5, title: "Kano", named: "kano")
        buttonImage22.tag = 22
        buttonImage22.addTarget(self,
                               action: #selector(self.buttonTapped(sender:)),
                               for: .touchUpInside)
        contentsView.addSubview(buttonImage22)
        
        let buttonImage23 = createimage(contentsView: contentsView, x: 151, y: 960.5, title: "Lautrec", named: "Lautrec")
        buttonImage23.tag = 23
        buttonImage23.addTarget(self,
                               action: #selector(self.buttonTapped(sender:)),
                               for: .touchUpInside)
        contentsView.addSubview(buttonImage23)
        
        let buttonImage24 = createimage(contentsView: contentsView, x: 282.5, y: 960.5, title: "Schiele", named: "Egon Schiele")
        buttonImage24.tag = 24
        buttonImage24.addTarget(self,
                               action: #selector(self.buttonTapped(sender:)),
                               for: .touchUpInside)
        contentsView.addSubview(buttonImage24)
        
        let buttonImage25 = createimage(contentsView: contentsView, x: 19.5, y: 1092, title: "Hollar", named: "Hollar")
        buttonImage25.tag = 25
        buttonImage25.addTarget(self,
                               action: #selector(self.buttonTapped(sender:)),
                               for: .touchUpInside)
        contentsView.addSubview(buttonImage25)
        
        let buttonImage26 = createimage(contentsView: contentsView, x: 151, y: 1092, title: "Millais", named: "John Everett Millais")
        buttonImage26.tag = 26
        buttonImage26.addTarget(self,
                               action: #selector(self.buttonTapped(sender:)),
                               for: .touchUpInside)
        contentsView.addSubview(buttonImage26)
        
        let buttonImage27 = createimage(contentsView: contentsView, x: 282.5, y: 1092, title: "Rembrandt", named: "Rembrandt")
        buttonImage27.tag = 27
        buttonImage27.addTarget(self,
                               action: #selector(self.buttonTapped(sender:)),
                               for: .touchUpInside)
        contentsView.addSubview(buttonImage27)
        
        let buttonImage28 = createimage(contentsView: contentsView, x: 19.5, y: 1223.5, title: "Anna Atkins", named: "Anna Atkins")
        buttonImage28.tag = 28
        buttonImage28.addTarget(self,
                               action: #selector(self.buttonTapped(sender:)),
                               for: .touchUpInside)
        contentsView.addSubview(buttonImage28)
        
        let buttonImage29 = createimage(contentsView: contentsView, x: 151, y: 1223.5, title: "Bruegel", named: "Bruegel")
        buttonImage29.tag = 29
        buttonImage29.addTarget(self,
                               action: #selector(self.buttonTapped(sender:)),
                               for: .touchUpInside)
        contentsView.addSubview(buttonImage29)
        
        let buttonImage30 = createimage(contentsView: contentsView, x: 282.5, y: 1223.5, title: "Delacroix", named: "Delacroix")
        buttonImage30.tag = 30
        buttonImage30.addTarget(self,
                               action: #selector(self.buttonTapped(sender:)),
                               for: .touchUpInside)
        contentsView.addSubview(buttonImage30)
        
        let buttonImage31 = createimage(contentsView: contentsView, x: 19.5, y: 1355, title: "Chagall", named: "chagall")
        buttonImage31.tag = 31
        buttonImage31.addTarget(self,
                               action: #selector(self.buttonTapped(sender:)),
                               for: .touchUpInside)
        contentsView.addSubview(buttonImage31)
        
        let buttonImage32 = createimage(contentsView: contentsView, x: 151, y: 1355, title: "Pollock", named: "pollock")
        buttonImage32.tag = 32
        buttonImage32.addTarget(self,
                               action: #selector(self.buttonTapped(sender:)),
                               for: .touchUpInside)
        contentsView.addSubview(buttonImage32)
        
        let buttonImage33 = createimage(contentsView: contentsView, x: 282.5, y: 1355, title: "Paulklee", named: "paulklee")
        buttonImage33.tag = 33
        buttonImage33.addTarget(self,
                               action: #selector(self.buttonTapped(sender:)),
                               for: .touchUpInside)
        contentsView.addSubview(buttonImage33)
        
        let buttonImage34 = createimage(contentsView: contentsView, x: 19.5, y: 1486.5, title: "Matisse", named: "Matisse")
        buttonImage34.tag = 34
        buttonImage34.addTarget(self,
                               action: #selector(self.buttonTapped(sender:)),
                               for: .touchUpInside)
        contentsView.addSubview(buttonImage34)
        
        let buttonImage35 = createimage(contentsView: contentsView, x: 151, y: 1486.5, title: "Kandinsky", named: "kandinsky")
        buttonImage35.tag = 35
        buttonImage35.addTarget(self,
                               action: #selector(self.buttonTapped(sender:)),
                               for: .touchUpInside)
        contentsView.addSubview(buttonImage35)
        
        let buttonImage36 = createimage(contentsView: contentsView, x: 282.5, y: 1486.5, title: "Picasso", named: "Picasso")
        buttonImage36.tag = 36
        buttonImage36.addTarget(self,
                               action: #selector(self.buttonTapped(sender:)),
                               for: .touchUpInside)
        contentsView.addSubview(buttonImage36)
        
        
        
        let label = createLabel(contentsView: contentsView)
        contentsView.addSubview(label)
        
        return contentsView
    }
    
    
    
    func configureSV() {
        
        // scrollViewにcontentsViewを配置させる
        let subView = createContentsView()
        scrollView.addSubview(subView)
        
        // scrollViewにcontentsViewのサイズを教える
        scrollView.contentSize = subView.frame.size
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


