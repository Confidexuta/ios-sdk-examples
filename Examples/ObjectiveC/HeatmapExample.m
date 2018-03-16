
#import "HeatmapExample.h"
@import Mapbox;

NSString *const MBXExampleHeatmap = @"HeatmapExample";

@interface HeatmapExample () <MGLMapViewDelegate>

@end

@implementation HeatmapExample

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create and add a map view.
    MGLMapView *mapView = [[MGLMapView alloc] initWithFrame:self.view.bounds styleURL:[MGLStyle darkStyleURL]];
    mapView.delegate = self;
    mapView.tintColor = [UIColor lightGrayColor];
    [self.view addSubview:mapView];
}

- (void)mapView:(MGLMapView *)mapView didFinishLoadingStyle:(MGLStyle *)style {
    // Parse GeoJSON data. This example uses all M1.0+ earthquakes from 12/22/15 to 1/21/16 as logged by USGS' Earthquake hazards program.
    NSURL *url = [NSURL URLWithString:@"https://www.mapbox.com/mapbox-gl-js/assets/earthquakes.geojson"];
    MGLShapeSource *source = [[MGLShapeSource alloc] initWithIdentifier:@"earthquakes" URL:url options:nil];
    [mapView.style addSource:source];
    
    
    // Create a heatmap layer.
    MGLHeatmapStyleLayer *layer = [[MGLHeatmapStyleLayer alloc] initWithIdentifier:@"earthquakes" source:source];
    
    NSDictionary *colorDictionary = @{ @0 : [UIColor clearColor],
                                       @0.01 : [UIColor whiteColor],
                                       @0.1 : [UIColor colorWithRed:0.19 green:0.3 blue:0.8 alpha:1.0],
                                       @0.5 : [UIColor colorWithRed:0.73 green:0.23 blue:0.25 alpha:1.0],
                                       @1 : [UIColor yellowColor]
                                       };
    layer.heatmapIntensity = [NSExpression expressionWithFormat:@"FUNCTION($zoomLevel, 'mgl_interpolateWithCurveType:parameters:stops:', 'linear', nil, %@)", @{@0: @1, @9: @3 }];
    layer.heatmapRadius = [NSExpression expressionWithFormat:@"FUNCTION($zoomLevel, 'mgl_interpolateWithCurveType:parameters:stops:', 'linear', nil, %@)", @{@0: @4, @9: @30}];
    layer.heatmapWeight = [NSExpression expressionWithFormat:@"FUNCTION(magnitude, 'mgl_interpolateWithCurveType:parameters:stops:', 'linear', nil, %@)", @{@0: @0, @6: @1}];
    layer.heatmapColor = [NSExpression expressionWithFormat:@"FUNCTION($heatmapDensity, 'mgl_interpolateWithCurveType:parameters:stops:', 'linear', nil, %@)", colorDictionary];
    layer.heatmapOpacity = [NSExpression expressionWithFormat:@"FUNCTION($zoomLevel, 'mgl_stepWithMinimum:stops:', 0.75, %@)", @{@9: @0}];
    [style addLayer:layer];
    
}

@end