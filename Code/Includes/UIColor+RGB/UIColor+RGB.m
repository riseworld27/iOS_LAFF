//
//  UIColor+utils.m
//  storink
//
//  Created by matata on 27.05.13.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import "UIColor+RGB.h"

@implementation UIColor (RGB)

+ (UIColor *) colorFromRGBString:(NSString *)hexstr {
    NSScanner *scanner;
    unsigned int rgbval;
	
    scanner = [NSScanner scannerWithString: hexstr];
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
    [scanner scanHexInt: &rgbval];
	
    return [UIColor colorFromRGB:rgbval];
}
+ (UIColor *) colorFromRGB:(NSInteger)rgb {
    return [UIColor colorWithRed:((float)((rgb & 0xFF0000) >> 16))/255.0
                           green:((float)((rgb & 0xFF00) >> 8))/255.0
                            blue:((float)(rgb & 0xFF))/255.0
                           alpha:1.0];
}
+ (UIColor *) colorFromRGB:(NSInteger)rgb andAlpha:(float)alpha {
    return [UIColor colorWithRed:((float)((rgb & 0xFF0000) >> 16))/255.0
                           green:((float)((rgb & 0xFF00) >> 8))/255.0
                            blue:((float)(rgb & 0xFF))/255.0
                           alpha:alpha];
}

@end
