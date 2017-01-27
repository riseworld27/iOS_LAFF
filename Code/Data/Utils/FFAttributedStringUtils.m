//
//  FFAttributedStringUtils.m
//  laff
//
//  Created by matata on 15.05.14.
//  Copyright (c) 2014 matata. All rights reserved.
//

#import "FFAttributedStringUtils.h"

@implementation FFAttributedStringUtils

+ (NSString *)cssStringFromAttributedStringAttributes:(NSDictionary *)dictionary {
    NSMutableString *cssString = [NSMutableString stringWithString:@"<style> body {"];
	
    if (dictionary[NSFontAttributeName]) {
        UIFont * font = dictionary[NSFontAttributeName];
        [cssString appendFormat:@"font-family: '%@'; font-size: %0.fpx;", font.fontName, roundf(font.pointSize)];
    }
	if (dictionary[NSForegroundColorAttributeName]) {
		UIColor * color = dictionary[NSForegroundColorAttributeName];
        [cssString appendFormat:@"color: #%@;", [FFAttributedStringUtils hexStringForColor:color]];
	}
    if (dictionary[NSParagraphStyleAttributeName]) {
        NSParagraphStyle * style = dictionary[NSParagraphStyleAttributeName];
        [cssString appendFormat:@"line-height: %0.1f em;", style.lineHeightMultiple];
    }
	
    [cssString appendString:@"}"];
    [cssString appendString:@"</style><body>"];
	
    return cssString;
}
+ (NSAttributedString *)attributedStringWithTextParams:(NSDictionary *)textParams andHTML:(NSString *)HTML {
    NSDictionary *importParams = @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
    NSString * formatString = [[self cssStringFromAttributedStringAttributes:textParams] stringByAppendingFormat:@"%@</body>", HTML];
    NSData *stringData = [formatString dataUsingEncoding:NSUnicodeStringEncoding] ;
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:stringData options:importParams documentAttributes:nil error:nil];
    
    return attributedString;
}
+ (NSString *)hexStringForColor:(UIColor *)color {
	const CGFloat *components = CGColorGetComponents(color.CGColor);
	CGFloat r = components[0];
	CGFloat g = components[1];
	CGFloat b = components[2];
	NSString *hexString=[NSString stringWithFormat:@"%02X%02X%02X", (int)(r * 255), (int)(g * 255), (int)(b * 255)];
	return hexString;
}

@end
