//
//  FFScreeningScheduleCell.m
//  laff
//
//  Created by matata on 30.04.14.
//  Copyright (c) 2014 matata. All rights reserved.
//

#import "FFScreeningScheduleCell.h"
#import "FFDateUtils.h"
#import "Event.h"
#import "FFConstants.h"

#import "UIColor+RGB.h"

#import <AFNetworking/UIImageView+AFNetworking.h>

NSString * const FFScreeningScheduleCellIdentifier = @"screening";
CGFloat const FFScreeningScheduleCellHeight = 92.f;

@interface FFScreeningScheduleCell ()

@property (weak, nonatomic) IBOutlet UIView *timeView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *filmImageView;
@property (weak, nonatomic) IBOutlet UILabel *filmTitle;
@property (weak, nonatomic) IBOutlet UILabel *filmSection;
@property (weak, nonatomic) IBOutlet UILabel *screeningVenueName;

@end

@implementation FFScreeningScheduleCell

- (void)updateWithScreening:(Screening *)screening {
	Event * event = screening.event;
	
    self.timeLabel.text   = [[FFDateUtils screeningScheduleDateFormatter] stringFromDate:screening.screeningDate];
    self.filmTitle.text   = event.eventTitle;
    self.filmSection.text = event.sectionName;
    self.screeningVenueName.text = screening.venueName;
	
	[self.filmImageView setImageWithURL:[NSURL URLWithString:event.filmImageURL] placeholderImage:[FFScreeningScheduleCell placeholderImage]];
}
+ (UIImage *)placeholderImage {
	static UIImage * placeholderImage;
	if (!placeholderImage) {
#ifdef LAFF
		placeholderImage = [UIImage imageNamed:@"image_placeholder_92x52"];
#elif NBFF
		placeholderImage = [UIImage imageNamed:@"nbff_image_placeholder_92x52"];
#endif
	}
	return placeholderImage;
}
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
	void (^changeValuesBlock)() = ^() {
		self.backgroundColor = highlighted ? [UIColor colorWithWhite:.7f alpha:1.f] : [UIColor whiteColor];
		self.timeView.backgroundColor = highlighted ? [UIColor blackColor] : [UIColor colorFromRGB:FFConstantTintColor];
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
