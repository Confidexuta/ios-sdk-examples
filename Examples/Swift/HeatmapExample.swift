//
//  HeatmapExample.swift
//  Examples
//
//  Created by Jordan Kiley on 2/23/18.
//  Copyright © 2018 Mapbox. All rights reserved.
//

import Mapbox

@objc(HeatmapExample_Swift)

class HeatmapExample: UIViewController, MGLMapViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        let mapView = MGLMapView(frame: view.bounds, styleURL: MGLStyle.darkStyleURL())
        mapView.delegate = self
        view.addSubview(mapView)
        
    }
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        guard let url = URL(string: "https://www.mapbox.com/mapbox-gl-js/assets/earthquakes.geojson") else { return }
        let source = MGLShapeSource(identifier: "earthquakes", url: url, options: nil)
        style.addSource(source)
        
        let colorDictionary = [0: UIColor.clear,
                               0.01 : UIColor.white.withAlphaComponent(0.5),
                               0.15 : UIColor(red:0.19, green:0.30, blue:0.80, alpha:1.0).withAlphaComponent(0.5),
                               0.5 : UIColor(red:0.73, green:0.23, blue:0.25, alpha:1.0).withAlphaComponent(0.5),
                               1 : UIColor.yellow.withAlphaComponent(0.5)
        ]
        let layer = MGLHeatmapStyleLayer(identifier: "earthquakes", source: source)
        layer.heatmapIntensity = NSExpression(format: "FUNCTION($zoomLevel, 'mgl_interpolateWithCurveType:parameters:stops:', 'linear', nil, %@)",
                                              [0: 1,
                                               9: 3])
        layer.heatmapRadius = NSExpression(format: "FUNCTION($zoomLevel, 'mgl_interpolateWithCurveType:parameters:stops:', 'linear', nil, %@)",
                                           [0: 2,
                                            9: 20])
        layer.heatmapWeight = NSExpression(format: "FUNCTION(magnitude, 'mgl_interpolateWithCurveType:parameters:stops:', 'linear', nil, %@)",
                                           [0: 0,
                                            6: 1])
        layer.heatmapColor = NSExpression(format: "FUNCTION($heatmapDensity, 'mgl_interpolateWithCurveType:parameters:stops:', 'linear', nil, %@)", colorDictionary)
        style.addLayer(layer)
    }

}
