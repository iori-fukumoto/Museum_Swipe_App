//
//  MusicDataModel.swift
//  MusicListApp
//
//  Created by 福本伊織 on 2021/03/09.
//

import Foundation
import Firebase
import PKHUD

/*
 let artistDisplayName = json2["artistDisplayName"].string
let primaryImage = json2["primaryImage"].string
let title = json2["title"].string
let objectDate = json2["objectDate"].string
 */

//SaveProfileモデルと同じ要領でやっていく
class DataModel {
    
    var artistDisplayName:String = ""
    var primaryImage:String = ""
    var title:String = ""
    var objectDate:String = ""
    var userID:String = ""
    var userName:String = ""
    
    let ref:DatabaseReference!
    
    var key:String! = ""
    
    init(artistDisplayName:String,primaryImage:String,title:String,objectDate:String,userID:String,userName:String){
        
        self.artistDisplayName = artistDisplayName
        self.primaryImage = primaryImage
        self.title = title
        self.objectDate = objectDate
        self.userID = userID
        self.userName = userName
        
        //ログインのときに拾えるuidを先頭につけて送信、受信する時もuidから引っ張ってくる
        //usersのuserIDの下に保存してくださいね、という意味。
        ref = Database.database().reference().child("users").child(userID).childByAutoId()
        
      
    }
    
    //これいつ使う？受信の時に使うらしい。
    init(snapshot:DataSnapshot) {
        
        
        ref = snapshot.ref
        if let value = snapshot.value as? [String:Any]{
            
            //保存した値をプロパティに入れていく。
            artistDisplayName = (value["artistDisplayName"] as? String)!
            primaryImage = (value["primaryImage"] as? String)!
            title = (value["title"] as? String)!
            objectDate = (value["objectDate"] as? String)!
            userID = (value["userID"] as? String)!
            userName = (value["userName"] as? String)!
            
        }
        
    }
    
    func toContents() -> [String:Any]{
        
        //イニシャライザで入ってきた値を辞書型にする。
        return ["artistDisplayName":artistDisplayName,"primaryImage":primaryImage,"title":title,"objectDate":objectDate,"userID":userID,"userName":userName]
        
    }
    
    //usersのuserIDの下にtoContents()で返された値を保存してくださいね、という意味。toContentsを一緒に書くこともできるがわかりやすいようにあえて分けている。
    func save(){
        
        //setValueでfireBaseに保存する。
        ref.setValue(toContents())
        
    }
    
    
}


