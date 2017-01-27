//
//  FFAboutTextCell.m
//  laff
//
//  Created by matata on 28.04.14.
//  Copyright (c) 2014 matata. All rights reserved.
//

#import "FFAboutTextCell.h"
#import "FFConstants.h"

NSString * const FFAboutTextCellIdentifier = @"aboutText";

@implementation FFAboutTextCell

- (void)awakeFromNib {
	[super awakeFromNib];
	self.textView.textContainer.lineFragmentPadding = 0;
	self.textView.textContainerInset = UIEdgeInsetsZero;
	self.textView.tintColor = [FFConstants tintColor];
}
+ (CGFloat)heightWithAText:(NSAttributedString *)atext width:(CGFloat)width {
	CGSize maxSize = CGSizeMake(width - 20.f, CGFLOAT_MAX);
	CGRect textSize = [atext boundingRectWithSize:maxSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil];
	return ceilf(CGRectGetHeight(textSize)) + 10.f + 10.f + 1.f;
}
+ (CGFloat)heightWithText:(NSString *)text width:(CGFloat)width {
	CGSize maxSize = CGSizeMake(width - 20.f, CGFLOAT_MAX);
	CGRect textSize = [text boundingRectWithSize:maxSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:16.f]} context:nil];
	return ceilf(CGRectGetHeight(textSize)) + 10.f + 10.f + 1.f;
}
+ (CGFloat)heightWithText:(NSString *)text font:(UIFont *)font width:(CGFloat)width {
	CGSize maxSize = CGSizeMake(width - 20.f, CGFLOAT_MAX);
	CGRect textSize = [text boundingRectWithSize:maxSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName:font} context:nil];
	return ceilf(CGRectGetHeight(textSize)) + 10.f + 10.f + 1.f;
}

@end
