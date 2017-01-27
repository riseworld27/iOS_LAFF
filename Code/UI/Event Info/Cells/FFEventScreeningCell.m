//
//  FFEventScreeningCell.m
//  laff
//
//  Created by matata on 5.05.14.
//  Copyright (c) 2014 matata. All rights reserved.
//

#import "FFEventScreeningCell.h"
#import "FFDateUtils.h"
#import "FFConstants.h"

NSString * const FFEventScreeningCellIdentifier = @"Event Screening";
CGFloat const FFEventScreeningCellHeight = 68.f;

@interface FFEventScreeningCell ()

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;

@end

@implementation FFEventScreeningCell

- (void)awakeFromNib {
	[super awakeFromNib];
	self.iconView.image = [[UIImage imageNamed:@"map_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	self.iconView.tintColor = [UIColor colorWithWhite:.8f alpha:1.f];
}
- (void)updateWithScreening:(Screening *)screening highlighted:(BOOL)highlighted hasLocation:(BOOL)hasLocation {
	self.dateLabel.text = [[FFDateUtils screeningScheduleDateFormatter] stringFromDate:screening.screeningDate];
	self.locationTitleLabel.text = screening.venueName;
	
	self.dateLabel.textColor = highlighted ? [FFConstants tintColor] : [UIColor darkGrayColor];
	self.locationTitleLabel.textColor = highlighted ? [UIColor darkGrayColor] : [UIColor colorWithWhite:.5f alpha:1.f];
	
	self.iconView.hidden = !hasLocation;
	self.selectionStyle = hasLocation ? UITableViewCellSelectionStyleDefault : UITableViewCellSelectionStyleNone;
}

@end
