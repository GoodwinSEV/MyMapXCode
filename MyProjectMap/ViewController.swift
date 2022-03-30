//
//  ViewController.swift
//  MyProjectMap
//
//  Created by Саввина Елена on 16.03.2022.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{

    @IBOutlet weak var mapView: MKMapView!
    
    //Переменные для создания маршрута
    var itemMapFirst: MKMapItem!
    var itemMapSecond: MKMapItem!
    
    //для работы с картой содается manager
    let manager: CLLocationManager = {
        
        let locationManager  = CLLocationManager() // получение местоположения
        
        locationManager.activityType = .fitness // fitness точно определяет местоположение
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // определить точность
        locationManager.distanceFilter = 1 //фильтр дистанции
        locationManager.showsBackgroundLocationIndicator = true //отобразить индикатор на карте
        locationManager.pausesLocationUpdatesAutomatically = true // отображение обновления
        
        return locationManager
    
    } ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        manager.delegate = self
        
        authorization() //вызываем функцию авторизации
        pinPosition() //вызываем функцию с точками на карте
        
        let touch = UILongPressGestureRecognizer(target: self, action: #selector(addPin(recogn:)))
        mapView.addGestureRecognizer(touch)
        
        manager.startUpdatingLocation()
        
    }

    //функция добавления точек на карты
    func pinPosition(){
        
        //Массивы с координатами
        let arrayLet = [62.03, 50.45]
        let arrayLon = [129.73, 30.52]
        
        //Добавление на карту
        for number in 0..<arrayLet.count {
            
            let point = MKPointAnnotation()
            point.title = "My point"
            point.coordinate = CLLocationCoordinate2D(latitude: arrayLet[number], longitude: arrayLon[number])
            mapView.addAnnotation(point)
        }
        
    }
    
    //Функция которая выдает нам координаты
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
      //отображение координат с помощью цикла
        for location in locations {
            
            print(location.coordinate.latitude)
            print(location.coordinate.longitude)
            itemMapFirst = MKMapItem(placemark: MKPlacemark(coordinate: location.coordinate))
    }
    }
    
    
    //функция авторизации
    func authorization () {
        
        //Проверка на разрешение использования местоположения (ALWAYS - всегда, INUSE - когда приложение открыто)
        if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            
            mapView.showsUserLocation = true //Отобразить на карте текущее местоположение пользователя
            
        } else {
            manager.requestWhenInUseAuthorization() //Запрос на использование местопложения пользователя
        }
            
    }
    
    //функция построения маршрута
    func calculayeRoute(){
        
        let request = MKDirections.Request() //Запрос на построение линии
        
        request.source = itemMapFirst //начальная точка
        request.destination = itemMapSecond //конечная точка
        request.requestsAlternateRoutes = true
        request.transportType = .walking //автомобили, дороги, все
        
        let direction = MKDirections(request: request)
       
        direction.calculate {(response, error) in
            
            guard let directionResponse = response else {return} //проверка
            
            let route = directionResponse.routes[0] //количество маршрутов
            
            self.mapView.addOverlay(route.polyline, level: .aboveRoads) //добавление линии на карте
        }
    }
    
    
    
    //функция для отрисовки линий
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let render = MKPolylineRenderer(overlay: overlay)
        render.lineWidth = 5
        render.strokeColor = .red
        return render
    }
    
    @objc func addPin (recogn: UIGestureRecognizer) {
        
        let newLocation = recogn.location(in: mapView)
        let newCoordinate = mapView.convert(newLocation, toCoordinateFrom: mapView)
        
        itemMapSecond = MKMapItem(placemark: MKPlacemark(coordinate: newCoordinate))
        
        let point = MKPointAnnotation()
        point.title = "Коечная точка"
        point.coordinate = newCoordinate
        mapView.addAnnotation(point)
        calculayeRoute()
        
    }

}


