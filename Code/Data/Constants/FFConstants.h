//
//  FFConstants.h
//  laff
//
//  Created by matata on 28.04.14.
//  Copyright (c) 2014 matata. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const FFConstantBaseAPIURLString;

extern NSInteger const FFConstantTintColor;

extern NSString * const FFConstantTwitterKey;
extern NSString * const FFConstantTwitterSecret;
extern NSString * const FFConstantTwitterUsername;

extern NSString * const FFConstantFacebookUsername;
extern NSString * const FFConstantFacebookID;

extern NSString * const FFConstantGoogleAnalyticsTrackingNumber;

@interface FFConstants : NSObject

+ (UIColor *)tintColor;

@end
