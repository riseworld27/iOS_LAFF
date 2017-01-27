//
//  FFScreeningLocationVC.m
//  laff
//
//  Created by matata on 5.05.14.
//  Copyright (c) 2014 matata. All rights reserved.
//

#import "FFScreeningLocationVC.h"
#import "FFScreeningMapAnnotation.h"

#import "GA.h"

#import <UIAlertView-Blocks/UIActionSheet+Blocks.h>

static NSString * const ANNOTATION_VIEW_DEFAULT_ID = @"default";

@interface FFScreeningLocationVC ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
//@property (nonatomic, assign) CLLocationCoordinate2D venueCoord;

@end

@implementation FFScreeningLocationVC

- (void)viewDidLoad {
    [super viewDidLoad];
	
	//// Setup Navigation
	
	self.navigationItem.title = self.location.venueName;
	
	UIBarButtonItem * directionsBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"direction_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(showDirections)];
	self.navigationItem.rightBarButtonItem = directionsBarButton;
	
	//// Setup Map View
	
	self.mapView.delegate = self;
	
//	self.venueCoord = CLLocationCoordinate2DMake(34.045784, -118.268094);
//	MKMapPoint venuePoint = MKMapPointForCoordinate(self.location.coordinate);
	
	FFScreeningMapAnnotation * venueAnnotation = [FFScreeningMapAnnotation new];
	venueAnnotation.coordinate = self.location.coordinate;
	venueAnnotation.title = self.location.venueName;
	
//	[self.mapView addAnnotation:venueAnnotation];
//	[self.mapView setCenterCoordinate:venueCoord animated:YES];
//	[self.mapView setVisibleMapRect:MKMapRectMake(venuePoint.x, venuePoint.y, 0, 0) animated:YES];
	
	[self.mapView showAnnotations:@[venueAnnotation] animated:YES];
}
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
	[tracker set:kGAIScreenName value:[@"Screening location > " stringByAppendingString:self.location.venueName]];
	[tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

//////////////////////////////////////////////////
#pragma mark - Map view delegate
//////////////////////////////////////////////////

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
	MKPinAnnotationView * annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:ANNOTATION_VIEW_DEFAULT_ID];
	if (!annotationView) {
		annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:ANNOTATION_VIEW_DEFAULT_ID];
		annotationView.animatesDrop = YES;
	}
	return annotationView;
}

//////////////////////////////////////////////////
#pragma mark - Bar button action
//////////////////////////////////////////////////

- (void)showDirections {
	void (^openInAppleMapsAction)() = ^() {
		MKPlacemark * placemark = [[MKPlacemark alloc] initWithCoordinate:self.location.coordinate addressDictionary:nil];
		MKMapItem * item = [[MKMapItem alloc] initWithPlacemark:placemark];
		item.name = self.location.venueName;
		[item openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving}];
	};
	
//	NSURL * googleMapsUrl = [NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?center=%f,%f", self.location.coordinate.latitude, self.location.coordinate.longitude]];
	NSURL * googleMapsUrl = [NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?daddr=%f,%f", self.location.coordinate.latitude, self.location.coordinate.longitude]];
	BOOL hasGoogleMapsApp = [[UIApplication sharedApplication] canOpenURL:googleMapsUrl];
	
	if (hasGoogleMapsApp) {
		RIButtonItem * openInAppleMaps = [RIButtonItem itemWithLabel:@"Apple Maps" action:openInAppleMapsAction];
		RIButtonItem * openInGoogleMaps = [RIButtonItem itemWithLabel:@"Google Maps" action:^(){
			[[UIApplication sharedApplication] openURL:googleMapsUrl];
		}];

		[[[UIActionSheet alloc] initWithTitle:@"Search for directions with" cancelButtonItem:[RIButtonItem itemWithLabel:@"Cancel"] destructiveButtonItem:nil otherButtonItems:openInAppleMaps, openInGoogleMaps, nil] showInView:self.view];
	} else {
		openInAppleMapsAction();
	}
}

@end
