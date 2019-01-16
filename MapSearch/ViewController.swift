//
//  ViewController.swift
//  MapSearch
//
//  Created by Munesada Yohei on 2019/01/16.
//  Copyright © 2019 Munesada Yohei. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

    // UI: マップ表示を行うView（Storyboardと連結）
    @IBOutlet weak var mapView: MKMapView!
    
    // UI: 検索バー（Stoaryboardと連結）
    @IBOutlet weak var searchBar: UISearchBar!

    // 位置情報を取得するマネージャー.
    let locationManager = CLLocationManager()
    
    // 画面がロードされたときに呼び出される.
    override func viewDidLoad() {
        // 親のメソッドを呼び出す（これはお決まりコード）
        super.viewDidLoad()
        
        // マップの delegate を設定します.
        self.mapView.delegate = self
        
        // 検索バーの delegate を設定します.
        self.searchBar.delegate = self
        
        // 位置情報取得処理の delegate を設定します.
        locationManager.delegate = self

        // 現在位置を取得するための権限を、ユーザーにリクエストする.
        // 初めてリクエストする場合には、認可後に「localManager(_, didChangeAuthorization)」が呼び出されます.
        self.locationManager.requestWhenInUseAuthorization()

        // (2回目以降の起動ではこちらが実行されます）
        // ユーザーから利用OKがOKの場合には、
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedWhenInUse {

            // Map表示を開始します.
            self.startMapDisplay()
        }
    }
    
    // Map表示を開始します.
    private func startMapDisplay() {
        
        // 10m ごとに取得するように設定します.
        locationManager.distanceFilter = 10
        
        // 位置情報の取得を開始.
        locationManager.startUpdatingLocation()
    }

}

// MARK: CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
    
    // ユーザーからの認可/不認可があった場合に呼び出されます.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
                
        // 位置情報取得がOKの場合、
        if status == .authorizedWhenInUse {
            // マップ表示を開始.
            self.startMapDisplay()
        }
    }
    
    // 位置情報を取得する度に、呼び出されます.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // 初めて位置情報を取得したら、
        if let location = locations.first {
            
            // 経緯度を取得します.
            let lat = location.coordinate.latitude
            let lng = location.coordinate.longitude
            print("latitude: \(lat), longitude: \(lng)")
            
            // 取得した経緯度が中心になるように、Mapの表示を変更します.
            let coords = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)  // 数字が小さいほど、拡大率Up.
            let region = MKCoordinateRegion(center: coords, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
}

// MARK: UISearchBarDelegate
extension ViewController: UISearchBarDelegate {
    
    // 検索バーでユーザーが検索したときに呼び出されます.
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        // キーボードを閉じます.
        searchBar.resignFirstResponder()
        
        // 検索条件を作成すます.
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBar.text
        
        // 検索範囲は、現在のマップ表示範囲と同じとします.
        request.region = self.mapView.region
        
        // 周辺検索を開始..
        let localSearch = MKLocalSearch(request: request)
        localSearch.start { result, error in
            
            // 検索結果を1つずつ処理します.
            for placemark in (result?.mapItems)! {
                
                // 検索した場所にピンを刺します.
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(
                    latitude: placemark.placemark.coordinate.latitude,
                    longitude: placemark.placemark.coordinate.longitude)
                annotation.title = placemark.name
                self.mapView.addAnnotation(annotation)
            }
        }
    }
}

// MARK: MkMapViewDelete
extension ViewController: MKMapViewDelegate {

    // マップで、アノテーションがタップされた場合に呼び出されます.
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // タイトルを取得して、
        if let title = view.annotation?.title ?? nil {
            // アラートで表示します.
            self.showAlert(message: title)
        }
    }
}
