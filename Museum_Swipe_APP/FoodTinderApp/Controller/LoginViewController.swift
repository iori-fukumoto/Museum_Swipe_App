
//
//  LoginViewController.swift
//  MusicListApp
//
//  Created by 福本伊織 on 2021/03/09.
//

import UIKit
import Firebase
import FirebaseAuth
//ボタンのグラデーション↓
import DTGradientButton

class LoginViewController: UIViewController,UITextFieldDelegate {

    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textField.delegate = self
        startButton.layer.cornerRadius = 25.0
        
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    
    
    @IBAction func login(_ sender: Any) {
        
        //もしtextFieldの値が空でない場合、
        if textField.text?.isEmpty != true{
            
            //textfieldの値をアプリ内に保存しとく
            UserDefaults.standard.set(textField.text, forKey: "userName")
            
        }else{
            
            //空なら、振動させる.UIKitの中にある。
            //インスタンス化
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            print("振動")
            
        }
        
        //以下resultが返ってきたら、FirebaseのAuthenticationの中にIDやら名前(textField.text)やらが入っている状態。ただし
        //以下68行目までをクロージャという。
        Auth.auth().signInAnonymously { (result, error) in
            
            //エラーがない場合
            if error == nil{
                
                //guardでエラー処理。resultにuserの値が返ってきてるかどうかの確認、エラー処理。
                guard let user = result?.user else
                {return}
                //userの中にはuserID(uid)も入ってるので、それを取り出して保存しておく。
                let userID = user.uid
                UserDefaults.standard.set(userID, forKey: "userID")
                //resultが返ってきたら、FirebaseのAuthenticationの中にIDやら名前(textField.text)やらが入っている状態。ただし、まだDBの中に値が入っていないのでそれをsaveProfile()を使って入れていく。クロージャの中なのでselfが必要。
                let saveProfile = SaveProfile(userID: userID, userName: self.textField.text!)
                saveProfile.saveProfile() //ここでDBに保存された
                //保存されたら閉じないといけない。クロジャーの中だからselfいる
                self.dismiss(animated: true, completion: nil)
                
                
            }else{
                
                print(error?.localizedDescription as Any)
                
            }
            
            let searchVC = self.storyboard?.instantiateViewController(identifier: "searchVC") as! SearchViewController
            self.navigationController?.pushViewController(searchVC, animated: true)
            
        }
        
        //.signInAnonymouslyの後に一旦ここ。通信したらresultかerrorが返ってくる。
        
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

