//
//  FFLatestNewsTitleCell.m
//  laff
//
//  Created by matata on 17.03.15.
//  Copyright (c) 2015 matata. All rights reserved.
//

#import "FFLatestNewsTitleCell.h"
#import "FFConstants.h"

#import "UIColor+RGB.h"

NSString * const FFLatestNewsTitleCellIdentifier = @"title";

@implementation FFLatestNewsTitleCell

- (void)awakeFromNib {
	[super awakeFromNib];
	
	self.field.textColor = [UIColor colorFromRGB:FFConstantTintColor];
}

@end
