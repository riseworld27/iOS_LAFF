//
//  FFScreeningLocation.m
//  laff
//
//  Created by matata on 20.05.14.
//  Copyright (c) 2014 matata. All rights reserved.
//

#import "FFScreeningLocation.h"

@implementation FFScreeningLocation

+ (instancetype)locationWithName:(NSString *)venueName latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude {
	
	return [FFScreeningLocation locationWithName:venueName code:nil latitude:latitude longitude:longitude];
}
+ (instancetype)locationWithName:(NSString *)venueName code:(NSString *)venueCode latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude {
	
	FFScreeningLocation * location = [FFScreeningLocation new];
	location.venueName = venueName;
	location.venueCode = venueCode;
	location.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
	return location;
}
- (void)setCoordinate:(CLLocationCoordinate2D)coordinate {
	_isKnown = YES;
	_coordinate = coordinate;
}
+ (instancetype)unknownLocation {
	static FFScreeningLocation * unknownLocation;
	if (!unknownLocation) {
		unknownLocation = [FFScreeningLocation new];
		unknownLocation.venueName = @"Unknown location";
	}
	return unknownLocation;
}
- (NSString *)description {
	return [NSString stringWithFormat:@"<FFScreeningLocation name:{%@} coords:{%.2f, %.2f}>", self.venueName, self.coordinate.latitude, self.coordinate.longitude];
}

@end
