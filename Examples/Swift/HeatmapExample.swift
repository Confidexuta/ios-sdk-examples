
import Mapbox

@objc(HeatmapExample_Swift)

class HeatmapExample: UIViewController, MGLMapViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create and add a map view.
        let mapView = MGLMapView(frame: view.bounds, styleURL: MGLStyle.darkStyleURL())
        mapView.delegate = self
        mapView.tintColor = .lightGray
        view.addSubview(mapView)
    }
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        // Parse GeoJSON data. This example uses all M1.0+ earthquakes from 12/22/15 to 1/21/16 as logged by USGS' Earthquake hazards program.
        guard let url = URL(string: "https://www.mapbox.com/mapbox-gl-js/assets/earthquakes.geojson") else { return }
        let source = MGLShapeSource(identifier: "earthquakes", url: url, options: nil)
        style.addSource(source)
        
        // Create a heatmap layer.
        let layer = MGLHeatmapStyleLayer(identifier: "earthquakes", source: source)
        
        // Create a stops.
        let colorDictionary : [NSNumber : UIColor] = [0 : .clear,
                               0.01 : .white,
                               0.15 : UIColor(red:0.19, green:0.30, blue:0.80, alpha:1.0),
                               0.5 : UIColor(red:0.73, green:0.23, blue:0.25, alpha:1.0),
                               1 : .yellow
        ]
        layer.heatmapColor = NSExpression.mgl_expression(forInterpolateFunction: .heatmapDensity, curveType: .linear, steps: colorDictionary)
        layer.heatmapIntensity = NSExpression.mgl_expression(forInterpolateFunction: .zoomLevel, curveType: .linear, steps: [0: 1, 9:3])
        layer.heatmapRadius = NSExpression.mgl_expression(forInterpolateFunction: .zoomLevel, curveType: .linear, steps: [0: 4, 9: 30])
        layer.heatmapWeight = NSExpression.mgl_expression(forInterpolateFunction: .init(rawValue: "magnitude"), curveType: .linear, steps: [0: 0, 6: 1])
//        layer.heatmapColor = NSExpression(format: "FUNCTION($heatmapDensity, 'mgl_interpolateWithCurveType:parameters:stops:', 'linear', nil, %@)", colorDictionary)

//        layer.heatmapIntensity = NSExpression(format: "FUNCTION($zoomLevel, 'mgl_interpolateWithCurveType:parameters:stops:', 'linear', nil, %@)",
//                                              [0: 1,
//                                               9: 3])
        
//        layer.heatmapRadius = NSExpression(format: "FUNCTION($zoomLevel, 'mgl_interpolateWithCurveType:parameters:stops:', 'linear', nil, %@)",
//                                           [0: 4,
//                                            9: 30])
        layer.heatmapWeight = NSExpression(format: "FUNCTION(magnitude, 'mgl_interpolateWithCurveType:parameters:stops:', 'linear', nil, %@)",
                                           [0: 0,
                                            6: 1])
        
        layer.heatmapOpacity = NSExpression(format: "FUNCTION($zoomLevel, 'mgl_stepWithMinimum:stops:', 0.75, %@)", [9: 0])
        
        style.addLayer(layer)
        
        // TODO: Add circle layer for higher zoom levels
        let magnitudeDictionary : [Double : UIColor] = [0 : .white,
                                                        2.5 : .yellow,
                                                        5 : UIColor(red:0.73, green:0.23, blue:0.25, alpha:1.0),
                                                        7.5 : UIColor(red:0.19, green:0.30, blue:0.80, alpha:1.0)
                                                        ]
        let circleLayer = MGLCircleStyleLayer(identifier: "circle-layer", source: source)
        circleLayer.circleColor = NSExpression(format: "FUNCTION(mag, 'mgl_interpolateWithCurveType:parameters:stops:', 'linear', nil, %@)", magnitudeDictionary)
        circleLayer.circleOpacity = NSExpression(format: "FUNCTION($zoomLevel, 'mgl_stepWithMinimum:stops:', 0, %@)", [9: 0.75])
        circleLayer.circleRadius = NSExpression(forConstantValue: 20)
        style.addLayer(circleLayer)
        
    }

}
