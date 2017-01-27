//
//  FFScreeningLocations.h
//  laff
//
//  Created by matata on 20.05.14.
//  Copyright (c) 2014 matata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FFScreeningLocation.h"

@interface FFScreeningLocations : NSObject

+ (instancetype)instance;

- (FFScreeningLocation *)locationWithName:(NSString *)locationName;
- (FFScreeningLocation *)locationWithCode:(NSString *)locationCode;

@end
