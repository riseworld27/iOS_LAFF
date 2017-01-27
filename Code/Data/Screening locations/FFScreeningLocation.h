//
//  FFScreeningLocation.h
//  laff
//
//  Created by matata on 20.05.14.
//  Copyright (c) 2014 matata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface FFScreeningLocation : NSObject

@property (nonatomic, strong) NSString * venueName;
@property (nonatomic, strong) NSString * venueCode;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, assign, readonly) BOOL isKnown;

+ (instancetype)locationWithName:(NSString *)venueName latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude;
+ (instancetype)locationWithName:(NSString *)venueName code:(NSString *)venueCode latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude;
+ (instancetype)unknownLocation;

@end
