//
//  FFScreeningLocationVC.h
//  laff
//
//  Created by matata on 5.05.14.
//  Copyright (c) 2014 matata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "FFScreeningLocation.h"

@interface FFScreeningLocationVC : UIViewController <MKMapViewDelegate>

@property (nonatomic, strong) FFScreeningLocation * location;

@end
