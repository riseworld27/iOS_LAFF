//
//  FFPlayingScreeningsCell.m
//  laff
//
//  Created by matata on 17.03.15.
//  Copyright (c) 2015 matata. All rights reserved.
//

#import "FFPlayingScreeningCell.h"
#import "Event.h"

#import <AFNetworking/UIImageView+AFNetworking.h>

NSString * const FFPlayingScreeningCellIdentifier = @"screening";
CGFloat const FFPlayingScreeningCellHeight = 92.f;

@interface FFPlayingScreeningCell ()

@property (weak, nonatomic) IBOutlet UIImageView *filmImageView;
@property (weak, nonatomic) IBOutlet UILabel *filmTitle;
@property (weak, nonatomic) IBOutlet UILabel *filmSection;
@property (weak, nonatomic) IBOutlet UILabel *screeningVenueName;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *filmTItleHeightConstraint;

@end

@implementation FFPlayingScreeningCell

- (void)awakeFromNib {
}
- (void)prepareForReuse {
	[super prepareForReuse];
	self.filmTItleHeightConstraint.constant = 40.f;
}
- (void)updateWithScreening:(Screening *)screening {
	Event * event = screening.event;
	
	self.filmTitle.text   = event.eventTitle;
	
	CGSize filmTitleSize = [self.filmTitle sizeThatFits:self.filmTitle.frame.size];
	if (filmTitleSize.height < 40) {
		self.filmTItleHeightConstraint.constant = filmTitleSize.height;
	}
	/*
	CGRect filmTitleFrame = self.filmTitle.frame;
	filmTitleFrame.size = filmTitleSize;
	self.filmTitle.frame = filmTitleFrame;
	 */
	
	self.filmSection.text = event.sectionName;
	self.screeningVenueName.text = @""; // screening.venueName;
	
	[self.filmImageView setImageWithURL:[NSURL URLWithString:event.filmImageURL] placeholderImage:[FFPlayingScreeningCell placeholderImage]];
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
		self.backgroundColor = highlighted ? [UIColor colorWithWhite:.25f alpha:1.f] : [UIColor blackColor];
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
