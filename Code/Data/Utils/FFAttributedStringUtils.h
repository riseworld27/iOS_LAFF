//
//  FFAttributedStringUtils.h
//  laff
//
//  Created by matata on 15.05.14.
//  Copyright (c) 2014 matata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FFAttributedStringUtils : NSObject

+ (NSAttributedString *)attributedStringWithTextParams:(NSDictionary *)textParams andHTML:(NSString *)HTML;

@end
