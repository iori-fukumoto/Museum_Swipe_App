//
//  ListViewController.swift
//  FoodTinderApp
//
//  Created by 福本伊織 on 2021/03/20.
//

import UIKit
import Firebase
import FirebaseAuth
import PKHUD

//ProfileのオートID以下をとってくる。
class ListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
   
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    var listRef = Database.database().reference()
    var getUserIDModelArray = [GetUserIDModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    
    
    
    
    //ナビゲーションバー表示
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        HUD.show(.success)
        //受信
        listRef.child("profile").observe(.value) { (snapShot) in
            
            HUD.hide()
            self.getUserIDModelArray.removeAll()
            
            //snapShotにオートID以下のデータが入ってくる
            for child in snapShot.children{
                
                //一個ずつDataSnapshot型にして、クラスに入れる。
                let childSnapshot = child as! DataSnapshot
                let listData = GetUserIDModel(snapshot: childSnapshot)
                
                //取得したデータを配列の先頭に入れていく
                self.getUserIDModelArray.insert(listData, at: 0)
                self.tableView.reloadData()
                
            }
            
            
            
        }
        
        
        
        
        
    }
    
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getUserIDModelArray.count
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 105
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        let listDataModel = getUserIDModelArray[indexPath.row]
        let userNameLabel = cell?.contentView.viewWithTag(1) as! UILabel
        userNameLabel.text = "\(String(describing: listDataModel.userName!))'s List"
        
        return cell!
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let otherVC = self.storyboard?.instantiateViewController(identifier: "otherVC") as! OtherPersonFavoriteViewController
        
        let listDataModel = getUserIDModelArray[indexPath.row]
        otherVC.userID = listDataModel.userID
        otherVC.userName = listDataModel.userName
        
        self.navigationController?.pushViewController(otherVC, animated: true)
        
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
