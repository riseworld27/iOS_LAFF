//
//  FFScreeningLocations.m
//  laff
//
//  Created by matata on 20.05.14.
//  Copyright (c) 2014 matata. All rights reserved.
//

#import "FFScreeningLocations.h"

@interface FFScreeningLocations ()

@property (nonatomic, strong) NSArray * locations;

@end

@implementation FFScreeningLocations

+ (instancetype)instance {
	static FFScreeningLocations * _instance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_instance = [FFScreeningLocations new];
	});
	return _instance;
}
- (id)init {
	self = [super init];
	if (self) {
#ifdef LAFF
		/*
		self.locations = @[
						   [FFScreeningLocation locationWithName:@"California Plaza" latitude:34.051652 longitude:-118.251637],
						   [FFScreeningLocation locationWithName:@"Luxe City Center Hotel" latitude:34.044478 longitude:-118.264250],
						   [FFScreeningLocation locationWithName:@"GRAMMY Museum" latitude:34.046046 longitude:-118.268121],
						   [FFScreeningLocation locationWithName:@"JW Marriott Pool" latitude:34.046046 longitude:-118.268121],
						   [FFScreeningLocation locationWithName:@"Nokia Plaza" latitude:34.046046 longitude:-118.268121],
						   [FFScreeningLocation locationWithName:@"Regal Cinemas 1" latitude:34.046046 longitude:-118.268121],
						   [FFScreeningLocation locationWithName:@"Regal Cinemas 8" latitude:34.046046 longitude:-118.268121],
						   [FFScreeningLocation locationWithName:@"Regal Cinemas 9" latitude:34.046046 longitude:-118.268121],
						   [FFScreeningLocation locationWithName:@"Regal Cinemas 10" latitude:34.046046 longitude:-118.268121],
						   [FFScreeningLocation locationWithName:@"Regal Cinemas 11" latitude:34.046046 longitude:-118.268121],
						   [FFScreeningLocation locationWithName:@"Regal Cinemas 12" latitude:34.046046 longitude:-118.268121],
						   [FFScreeningLocation locationWithName:@"Regal Cinemas 13" latitude:34.046046 longitude:-118.268121],
						   [FFScreeningLocation locationWithName:@"Regal Cinemas 14" latitude:34.046046 longitude:-118.268121],
						   [FFScreeningLocation locationWithName:@"Festival Lounge" latitude:34.045146 longitude:-118.268649],
						   [FFScreeningLocation locationWithName:@"Bing at LACMA" latitude:34.063271 longitude:-118.357627],
						   [FFScreeningLocation locationWithName:@"Conga room" latitude:34.046046 longitude:-118.268121],
						   [FFScreeningLocation locationWithName:@"Union Station" latitude:34.056437 longitude:-118.236507],
						   ];
		 */
		
		// The GRAMMY Museum at L.A. Live
		// Festival Lounge
		// Premiere House -- 34.045679,-118.268037
		// Regal 8
		// Regal 9
		// Regal 10
		// Regal 11
		// Regal 12
		// Regal 13
		// Regal 14

		self.locations = @[
						   [FFScreeningLocation locationWithName:@"The GRAMMY Museum at L.A. Live" latitude:34.046046 longitude:-118.268121],
						   [FFScreeningLocation locationWithName:@"Festival Lounge" latitude:34.045146 longitude:-118.268649],
						   [FFScreeningLocation locationWithName:@"Premiere House" latitude:34.045679 longitude:-118.268037],
						   [FFScreeningLocation locationWithName:@"Regal Cinemas L.A. LIVE 8" latitude:34.046046 longitude:-118.268121],
						   [FFScreeningLocation locationWithName:@"Regal Cinemas L.A. LIVE 9" latitude:34.046046 longitude:-118.268121],
						   [FFScreeningLocation locationWithName:@"Regal Cinemas L.A. LIVE 10" latitude:34.046046 longitude:-118.268121],
						   [FFScreeningLocation locationWithName:@"Regal Cinemas L.A. LIVE 11" latitude:34.046046 longitude:-118.268121],
						   [FFScreeningLocation locationWithName:@"Regal Cinemas L.A. LIVE 12" latitude:34.046046 longitude:-118.268121],
						   [FFScreeningLocation locationWithName:@"Regal Cinemas L.A. LIVE 13" latitude:34.046046 longitude:-118.268121],
						   [FFScreeningLocation locationWithName:@"Regal Cinemas L.A. LIVE 14" latitude:34.046046 longitude:-118.268121],
		];

#elif NBFF
		self.locations = @[
						   [FFScreeningLocation locationWithName:@"Big Newport Theater" code:@"B" latitude:33.612904 longitude:-117.873453],
						   [FFScreeningLocation locationWithName:@"Lido Live Theater" code:@"L" latitude:33.618262 longitude:-117.929461],
						   [FFScreeningLocation locationWithName:@"Starlight Triangle 8 Cinemas" code:@"S" latitude:33.6418422 longitude:-117.9186403],
						   [FFScreeningLocation locationWithName:@"Island Cinemas, Fashion Island" code:@"I" latitude:33.614989 longitude:-117.878161],
						   [FFScreeningLocation locationWithName:@"Regency South Coast Village" code:@"V" latitude:33.694998 longitude:-117.888814],
						   [FFScreeningLocation locationWithName:@"Orange County Museum of Art" code:@"O" latitude:33.621981 longitude:-117.878017],
						   [FFScreeningLocation locationWithName:@"The Studio at Sage Hill" code:@"H" latitude:33.735761 longitude:-117.814636],
						   [FFScreeningLocation locationWithName:@"SOCO" code:@"C" latitude:33.692200 longitude:-117.924736],
						   ];
#endif
	}
	return self;
}

//////////////////////////////////////////////////
#pragma mark - Public
//////////////////////////////////////////////////

- (FFScreeningLocation *)locationWithName:(NSString *)locationName {
	NSUInteger locationIndex = [self.locations indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
		FFScreeningLocation * location = obj;
		return [location.venueName compare:locationName options:NSCaseInsensitiveSearch] == NSOrderedSame;
	}];
	return locationIndex == NSNotFound ? [FFScreeningLocation unknownLocation] : self.locations[locationIndex];
}
- (FFScreeningLocation *)locationWithCode:(NSString *)locationCode {
	NSUInteger locationIndex = [self.locations indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
		FFScreeningLocation * location = obj;
		return [location.venueCode compare:locationCode options:NSCaseInsensitiveSearch] == NSOrderedSame;
	}];
	return locationIndex == NSNotFound ? [FFScreeningLocation unknownLocation] : self.locations[locationIndex];
}

@end
