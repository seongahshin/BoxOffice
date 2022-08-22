//
//  ViewController.swift
//  BoxOffice
//
//  Created by 신승아 on 2022/08/22.
//

import UIKit
import Alamofire
import RealmSwift
import SnapKit
import SwiftyJSON

class ViewController: UIViewController {
    
    let localRealm = try! Realm()
    var tasks: Results<BoxOffice>!
    var movieList: [String] = []
    
    
    let tableView: UITableView = {
        let view = UITableView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Realm is located at:", localRealm.configuration.fileURL!)
        print(UserDefaults.standard.bool(forKey: "launchBefore"))
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        
        
        if UserDefaults.standard.bool(forKey: "launchBefore") == false {
            callRequest()
        } else {
            count()
        }
        tasks = localRealm.objects(BoxOffice.self).sorted(byKeyPath: "movieTitle", ascending: false)
        tableView.reloadData()
    }
    
    
    
    func callRequest() {
        print(#function)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let date = Date(timeInterval: -(60*60*24), since: Date())
        let current_date_string = formatter.string(from: date)
        
        let url = "\(EndPoint.MovieURL)key=\(APIKey.MovieAPIKey)&targetDt=\(current_date_string)"
        print(url)
        AF.request(url, method: .get).validate().responseData { [self] response in
            switch response.result {
                    case .success(let value):

                        let json = JSON(value)
                        print("JSON: \(json)")
                
                        if UserDefaults.standard.bool(forKey: "launchBefore") == false {
                            for num in 0...json["boxOfficeResult"]["dailyBoxOfficeList"].count - 1 {
                            movieList.append(json["boxOfficeResult"]["dailyBoxOfficeList"][num]["movieNm"].stringValue)
                        }
            
                        print(movieList)
                        UserDefaults.standard.set(movieList, forKey: "movieList")
                        count()
                    
                        }
                        
                    case .failure(let error):
                        print(error)
                    }
                        
                
                        
                    
            }
        }
    
    func count() {
        print(#function)
        guard let boxOfficeList = UserDefaults.standard.array(forKey: "movieList") else { return }
        print("list \(boxOfficeList)")
        if UserDefaults.standard.bool(forKey: "launchBefore") == false {
            for num in 0...boxOfficeList.count - 1 {
                let task = BoxOffice(movieTitle: boxOfficeList[num] as! String)
                try! localRealm.write {
                    localRealm.add(task)
                }
                print("task \(task)")
                print(tasks!)

            }
            tableView.reloadData()
        }
        UserDefaults.standard.set(true, forKey: "launchBefore")
    }
}
    
    
    


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        let row = tasks[indexPath.row]
        cell?.textLabel?.text = row.movieTitle
        return cell!
    }
}
