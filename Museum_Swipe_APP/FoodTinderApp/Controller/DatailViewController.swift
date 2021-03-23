//
//  DatailViewController.swift
//  FoodTinderApp
//
//  Created by 福本伊織 on 2021/03/19.
//

import UIKit
import SDWebImage
import Firebase
import EMAlertController

class DatailViewController: UIViewController {

    var userID = String()
    var userName = String()
    var imageString = String()
    var artistDisplayNameString = String()
    var titleString = String()
    var objectDateString = String()
    
    var ref = Database.database().reference()
    var autoID = String()
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var objectDateLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        //渡ってきた値を入れていく
        imageView.sd_setImage(with: URL(string: imageString),placeholderImage: UIImage(named: "progress"),completed: nil)
        titleLabel.text = titleString
        artistNameLabel.text = artistDisplayNameString
        objectDateLabel.text = objectDateString
        
        
        
        
        //textView入力の時にその分上げる。メソッドは下のほうに記載。
        let notification = NotificationCenter.default
        
        notification.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        notification.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Do any additional setup after loading the view.
    }
    
    
    
    
    
   /* override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
    }*/
    
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    
    
    
    
    @IBAction func share(_ sender: Any) {
        
        
        //アクティビティViewにItem(textViewのText,captionString,passedURL)を掲載する。Share
        let activityItems = [imageView.image as Any,"\(textView.text!)\n\nアーティスト:\(artistDisplayNameString)\n作品名:\(titleString)\n年代:\(objectDateString)\n#メトロポリタン美術館"] as [Any]
        let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        
        activityController.popoverPresentationController?.sourceView = self.view
        activityController.popoverPresentationController?.sourceRect = self.view.frame
        
        self.present(activityController, animated: true, completion: nil)
        
    }
    
    
    
    
    @IBAction func Delite(_ sender: Any) {
        
        //アラート
        let alert = EMAlertController(icon: UIImage(named: "!!"), title: "Yes or Cancel", message: "削除しますか？")
        let cancel = EMAlertAction(title: "CANCEL", style: .cancel)
        let confirm = EMAlertAction(title: "OK", style: .normal) {
            
        
            self.ref.child("users").child(self.userID).child(self.autoID).removeValue()
        print("削除しました。")
        self.navigationController?.popViewController(animated: true)
            
    }
        
        alert.addAction(cancel)
        alert.addAction(confirm)
        present(alert, animated: true, completion: nil)
        
    }
    
    
    
    
    
    //キーボードが上がってくる
    @objc func keyboardWillShow(notification: Notification?) {
        let rect = (notification?.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        let duration: TimeInterval? = notification?.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        UIView.animate(withDuration: duration!) {
            self.view.transform = CGAffineTransform(translationX: 0, y: -(rect?.size.height)!)
        }
    }
    
    //キーボードが下がる
    @objc func keyboardWillHide(notification: Notification?) {
        let duration: TimeInterval? = notification?.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Double
        UIView.animate(withDuration: duration!) {
            self.view.transform = CGAffineTransform.identity
        }
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
