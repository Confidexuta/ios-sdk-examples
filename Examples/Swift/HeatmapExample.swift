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

        let mapView = MGLMapView(frame: view.bounds)
        mapView.delegate = self
        view.addSubview(mapView)
        
    }
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        guard let url = URL(string: "https://www.mapbox.com/mapbox-gl-js/assets/earthquakes.geojson") else { return }
        let source = MGLShapeSource(identifier: "earthquakes", url: url, options: nil)
        style.addSource(source)
        
        let colorDictionary = [0: UIColor.clear,
                               0.1 : UIColor.black.withAlphaComponent(0.5),
                               0.15 : UIColor.blue.withAlphaComponent(0.5),
                               0.75 : UIColor.red.withAlphaComponent(0.5),
                               1 : UIColor.yellow.withAlphaComponent(0.5)]
        let layer = MGLHeatmapStyleLayer(identifier: "earthquakes", source: source)
        layer.heatmapIntensity = NSExpression(forConstantValue: 0.5)
        layer.heatmapWeight = NSExpression(format: "FUNCTION(magnitude, 'mgl_interpolateWithCurveType:parameters:stops:', 'linear', nil, %@)",
                                           [0: 0,
                                            6: 1])
        layer.heatmapColor = NSExpression(format: "FUNCTION($heatmapDensity, 'mgl_interpolateWithCurveType:parameters:stops:', 'linear', nil, %@)", colorDictionary)
        style.addLayer(layer)
    }

}
