//
//  FFEventGetTicketsCell.m
//  laff
//
//  Created by matata on 30.04.14.
//  Copyright (c) 2014 matata. All rights reserved.
//

#import "FFEventGetTicketsCell.h"
#import "UIColor+RGB.h"

NSString * const FFEventGetTicketsCellIdentifier = @"Get Tickets";
CGFloat const FFEventGetTicketsCellHeight = 60.f;

@interface FFEventGetTicketsCell ()

@property (weak, nonatomic) IBOutlet UIView *getTicketsBG;

@end

@implementation FFEventGetTicketsCell

- (void)awakeFromNib {
	self.getTicketsBG.layer.masksToBounds = YES;
	self.getTicketsBG.layer.cornerRadius = 3.f;
}
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
	void (^changeValuesBlock)() = ^() {
		self.backgroundColor = highlighted ? [UIColor blackColor] : [UIColor colorFromRGB:0x0B0D1C];
		self.getTicketsBG.backgroundColor = highlighted ? [UIColor colorFromRGB:0x248A18] : [UIColor colorFromRGB:0x32B926];
	};
	if (highlighted) {
		changeValuesBlock();
	} else {
		[UIView animateWithDuration:.4f animations:changeValuesBlock];
	}
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[self setHighlighted:selected animated:animated];
}

@end
