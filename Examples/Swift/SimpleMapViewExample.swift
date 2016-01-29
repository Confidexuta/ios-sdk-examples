//
//  SimpleMapViewExample.swift
//  Examples
//
//  Created by Jason Wray on 1/28/16.
//  Copyright © 2016 Mapbox. All rights reserved.
//

import Mapbox

@objc(SimpleMapViewExample_Swift)

class SimpleMapViewExample_Swift: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let mapView = MGLMapView(frame: view.bounds)
        mapView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]

        // set the map's center coordinate
        mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: 40.7326808, longitude: -73.9843407), zoomLevel: 12, animated: false)
        view.addSubview(mapView)
    }
}
