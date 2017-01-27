//
//  FFConstants.m
//  laff
//
//  Created by matata on 28.04.14.
//  Copyright (c) 2014 matata. All rights reserved.
//

#import "FFConstants.h"
#import "UIColor+RGB.h"

//NSString * const FFConstantBaseAPIURLString = @"http://filmguide.lafilmfest.com/tixSYS/2012/spryguide/data/";
//NSString * const FFConstantBaseAPIURLString = @"http://filmguide.lafilmfest.com/tixSYS/2014/spryguide/data/title.php";
//NSString * const FFConstantBaseAPIURLString = @"http://107.170.155.172/";

NSString * const FFConstantTwitterKey = @"xtTEqh55g5T94oNdRLbvIVKH2";
NSString * const FFConstantTwitterSecret = @"431SmbBxVOB8P8cjSQ8DHPcbJseO4oTWKTuHqT9nz5rj0DRW5n";

#ifdef LAFF

NSInteger const FFConstantTintColor = 0xEA574C;

NSString * const FFConstantTwitterUsername = @"LaFilmFest";
NSString * const FFConstantFacebookUsername = @"LAFilmFest";
NSString * const FFConstantFacebookID = @"14246971089";
NSString * const FFConstantBaseAPIURLString = @"http://filmfest.io/accounts/1/";
NSString * const FFConstantGoogleAnalyticsTrackingNumber = @"UA-50538942-1";

#elif NBFF

NSInteger const FFConstantTintColor = 0xec2326;

NSString * const FFConstantTwitterUsername = @"nbff";
NSString * const FFConstantFacebookUsername = @"newportbeachfilmfest";
NSString * const FFConstantFacebookID = @"138435559028";
NSString * const FFConstantBaseAPIURLString = @"http://filmfest.io/accounts/2/";
NSString * const FFConstantGoogleAnalyticsTrackingNumber = @"UA-61557994-1";

#endif

@implementation FFConstants

+ (UIColor *)tintColor {
	static UIColor * _tintColor;
	if (!_tintColor) {
		_tintColor = [UIColor colorFromRGB:FFConstantTintColor];
	}
	return _tintColor;
}

@end
