//
//  ReceiverMapViewController.m
//  FlingMapDemo
//
//  Created by Ryo.x on 14/10/25.
//  Copyright (c) 2014年 Ryo.x. All rights reserved.
//

#import "ReceiverMapViewController.h"
#import <MapKit/MapKit.h>
#import "PhotoMarkView.h"

@interface ReceiverMapViewController ()<MKMapViewDelegate, PhotoMarkViewDelegate> {
    MKMapView *receiverMapView;
    PhotoMarkView *pmView;
}

@end

#define MINIMUM_ZOOM_ARC 0.014  //approximately 1 miles (1 degree of arc ~= 69 miles)
#define ANNOTATION_REGION_PAD_FACTOR 1.15
#define MAX_DEGREES_ARC 360

#define DEFAULT_MAP_REGION_CENTER_LATITUDE 35.773823
#define DEFAULT_MAP_REGION_CENTER_LONGITUDE 103.183594
#define DEFAULT_MAP_SPAN_LATITUDEDELTA 74.000145
#define DEFAULT_MAP_SPAN_LONGITUDEDELTA 55.546877

@implementation ReceiverMapViewController

+ (id)shareInstance {
    static ReceiverMapViewController *shareVC = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        shareVC = [[ReceiverMapViewController alloc] init];
    });
    
    return shareVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(dismissVC:)];
    
    receiverMapView = [[MKMapView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    receiverMapView.zoomEnabled = NO;
    receiverMapView.scrollEnabled = NO;
    receiverMapView.pitchEnabled = NO;
    receiverMapView.rotateEnabled = NO;
    receiverMapView.delegate = self;
    [self.view addSubview:receiverMapView];
    
//    defaultRegion = receiverMapView.region;
    
//    NSLog(@"%f, %f, %f, %f", defaultRegion.center.latitude, defaultRegion.center.longitude, defaultRegion.span.latitudeDelta, defaultRegion.span.longitudeDelta);
    
    //加了个透明的view  再添加MessageInputView就没事了。。。
    UIView *clearView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    clearView.backgroundColor = [UIColor clearColor];
    [clearView addGestureRecognizer:tapGesture];
    [self.view addSubview:clearView];
    
    pmView = [[PhotoMarkView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    pmView.delegate = self;
    [clearView addSubview:pmView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [pmView setPhoto4Fling:_photo];

}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [pmView resetDefaultLayout];
    [self resetDefaultLayout];
}

- (void)resetDefaultLayout {
    [receiverMapView removeAnnotations:receiverMapView.annotations];
    
    MKCoordinateRegion region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(DEFAULT_MAP_REGION_CENTER_LATITUDE,
                                                                                  DEFAULT_MAP_REGION_CENTER_LONGITUDE),
                                                       MKCoordinateSpanMake(DEFAULT_MAP_SPAN_LATITUDEDELTA,
                                                                            DEFAULT_MAP_SPAN_LONGITUDEDELTA));
    
    [receiverMapView setRegion:region];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    static NSString *identifier = @"Annotation";
    
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    if (pinView == nil) {
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                  reuseIdentifier:identifier];
        pinView.pinColor = MKPinAnnotationColorRed;
        pinView.animatesDrop = YES;
    }
    
    return pinView;
}

- (void)dismissVC:(UITapGestureRecognizer *)recognizer {
    if (pmView.alpha == 0) {
        NSLog(@"tap dismiss");
        [self dismissViewControllerAnimated:NO completion:NULL];
    }
}

- (void)displayReceiverLocation:(NSArray *)coordinateArray {
    for (NSValue *coordinateValue in coordinateArray) {
        CLLocationCoordinate2D coordinate = [coordinateValue MKCoordinateValue];
        
        MKPointAnnotation *pointAnnotation = [[MKPointAnnotation alloc] init];
        pointAnnotation.coordinate = coordinate;
        [receiverMapView addAnnotation:pointAnnotation];
    }
    
    [self zoomMapViewToFitAnnotations:receiverMapView animated:YES];
    
    [self autoDismiss];
}

- (void)autoDismiss {
    if (pmView.alpha == 0) {
        double delayInSeconds = 5.0;
        dispatch_time_t dismissTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(dismissTime, dispatch_get_main_queue(), ^(void){
            [self dismissViewControllerAnimated:NO completion:NULL];
        });
    }
}

- (void)photoMarkDidCanceled:(PhotoMarkView *)photoMarkView {
    if (self) {
        [self dismissViewControllerAnimated:NO
                                 completion:^{
                                     [photoMarkView resetDefaultLayout];
                                 }];
    }
}

- (void)photoFlingAnimationDidFinished:(PhotoMarkView *)photoMarkView {
    if (_coordinateArray.count > 0) {
        [self displayReceiverLocation:_coordinateArray];
    }
}

- (void)zoomMapViewToFitAnnotations:(MKMapView *)mapView animated:(BOOL)animated {
    NSArray *annotations = mapView.annotations;
    NSUInteger count = [mapView.annotations count];
    if (count == 0) {
        return;
    }   //bail if no annotations
    
    //convert NSArray of id <MKAnnotation> into an MKCoordinateRegion that can be used to set the map size
    //can't use NSArray with MKMapPoint because MKMapPoint is not an id
    MKMapPoint points[count]; //C array of MKMapPoint struct
    
    for( int i = 0; i < count; i++ ) {  //load points C array by converting coordinates to points
        CLLocationCoordinate2D coordinate = [(id<MKAnnotation>)[annotations objectAtIndex:i] coordinate];
        points[i] = MKMapPointForCoordinate(coordinate);
    }
    
    //create MKMapRect from array of MKMapPoint
    MKMapRect mapRect = [[MKPolygon polygonWithPoints:points count:count] boundingMapRect];
    //convert MKCoordinateRegion from MKMapRect
    MKCoordinateRegion region = MKCoordinateRegionForMapRect(mapRect);
    
    //add padding so pins aren't scrunched on the edges
    region.span.latitudeDelta *= ANNOTATION_REGION_PAD_FACTOR;
    region.span.longitudeDelta *= ANNOTATION_REGION_PAD_FACTOR;
    
    //but padding can't be bigger than the world
    if(region.span.latitudeDelta > MAX_DEGREES_ARC) {
        region.span.latitudeDelta = MAX_DEGREES_ARC;
    }
    
    if(region.span.longitudeDelta > MAX_DEGREES_ARC) {
        region.span.longitudeDelta = MAX_DEGREES_ARC;
    }
    
    //and don't zoom in stupid-close on small samples
    if(region.span.latitudeDelta < MINIMUM_ZOOM_ARC) {
        region.span.latitudeDelta = MINIMUM_ZOOM_ARC;
    }
    
    if(region.span.longitudeDelta < MINIMUM_ZOOM_ARC) {
        region.span.longitudeDelta = MINIMUM_ZOOM_ARC;
    }
    
    //and if there is a sample of 1 we want the max zoom-in instead of max zoom-out
    if(count == 1) {
        region.span.latitudeDelta = MINIMUM_ZOOM_ARC;
        region.span.longitudeDelta = MINIMUM_ZOOM_ARC;
    }
    
    [mapView setRegion:region animated:animated];
}

@end
