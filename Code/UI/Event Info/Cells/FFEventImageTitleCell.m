//
//  FFEventImageTitleCell.m
//  laff
//
//  Created by matata on 30.04.14.
//  Copyright (c) 2014 matata. All rights reserved.
//

#import "FFEventImageTitleCell.h"
#import "FFConstants.h"

#import "UIColor+RGB.h"
#import "Event+Description.h"

#import <MagicalRecord/CoreData+MagicalRecord.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <Lyt/Lyt.h>

NSString * const FFEventImageTitleCellIdentifier = @"eventImageTitle";
CGFloat const FFEventImageTitleCellHeight = 180.f;
CGFloat const MAX_PARALLAX_OFFSET = 30.f;

@interface FFEventImageTitleCell ()

@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *heartButton;
//@property (weak, nonatomic) IBOutlet SVBlurView *titleBackground;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgImageViewCenterConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *playIconView;

@property (nonatomic, strong) UIImage * bgImage;
@property (nonatomic, strong) UIView * highlightView;

@property (nonatomic, assign) BOOL isFavorite;
@property (nonatomic, assign) BOOL parallaxAvailable;
@property (nonatomic, assign) float parallaxPercent;

@property (nonatomic, strong) NSDate * imageLoadingStartTime;

@end

@implementation FFEventImageTitleCell

- (void)awakeFromNib {
	[super awakeFromNib];
	
//	[self.heartButton setImage:[UIImage imageNamed:@"heart_filled"] forState:(UIControlStateSelected|UIControlStateHighlighted)];
	
	self.highlightView = [[UIView alloc] initWithFrame:self.bounds];
//	self.highlightView = [UIView new];
	self.highlightView.backgroundColor = [UIColor colorFromRGB:FFConstantTintColor andAlpha:.4f];
	self.highlightView.hidden = YES;
	[self.contentView insertSubview:self.highlightView aboveSubview:self.bgImageView];
	self.highlightView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.highlightView lyt_alignToParent];
	
	self.bgImageView.contentMode = UIViewContentModeScaleAspectFill;
	self.clipsToBounds = YES;
	self.parallaxAvailable = NO;
	
	/*
	self.titleBackground.viewToBlur = self.bgImageView;
	self.titleBackground.blurRadius = 10.f;
	self.titleBackground.saturationDelta = 1.8f;
	self.titleBackground.tintColor = [UIColor colorWithWhite:0.11 alpha:0.23];
	self.titleBackground.clipsToBounds = YES;
	 */
}
//- (void)prepareForReuse {
//	[super prepareForReuse];
//}
- (void)setEvent:(Event *)event {
	if (event == _event) return;
	
	BOOL hasYoutubeVideo = event.filmClipURL && event.filmClipURL.length;
	self.playIconView.hidden = !hasYoutubeVideo;

	self.parallaxAvailable = NO;
	self.bgImage = nil;
	
	self.titleLabel.text = event.eventTitle;
	
	_isFavorite = [event.isFavorite boolValue];
	self.heartButton.selected = _isFavorite;
	
	self.descriptionLabel.text = event.description;
	
	NSURL * imageURL = [NSURL URLWithString:event.filmImageURL];
	if (imageURL) {
//		[self.bgImageView setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"image_placeholder_320x180"]];
//		NSLog(@"Loading image with URL: %@", imageURL);
		NSURLRequest * request = [NSURLRequest requestWithURL:imageURL];
		UIImage * placeholder = self.placeholderImage;
		__weak FFEventImageTitleCell * weakself = self;
		self.imageLoadingStartTime = [NSDate new];
		[self.bgImageView setImageWithURLRequest:request placeholderImage:placeholder success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			weakself.bgImage = image;
//			NSLog(@"Image load complete: %@", imageURL);
		} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//			NSLog(@"Image load failed: %@, error: %@", imageURL, error);
			weakself.bgImage = nil;
//			if (error.code == NSURLErrorCancelled) {
//			} else {
//			}
		}];
	}
	
	_event = event;
}
- (UIImage *)placeholderImage {
	static UIImage * placeholderImage;
	if (!placeholderImage) {
#ifdef LAFF
		placeholderImage = [UIImage imageNamed:@"image_placeholder_320x180"];
#elif NBFF
		placeholderImage = [UIImage imageNamed:@"nbff_image_placeholder_320x180"];
#endif
	}
	return placeholderImage;
}
- (void)setBgImage:(UIImage *)bgImage {
	//// Update image
	if (bgImage) {
		void (^setImageBlock)() = ^(){
			self.bgImageView.image = bgImage;
		};
		if (-self.imageLoadingStartTime.timeIntervalSinceNow > 0.1f) {
			[UIView transitionWithView:self.bgImageView
							  duration:0.4f
							   options:UIViewAnimationOptionTransitionCrossDissolve
							animations:setImageBlock
							completion:nil];
		} else {
			setImageBlock();
		}
	} else {
		self.bgImageView.image = self.placeholderImage;
	}
	
	//// Update constraints
	self.parallaxAvailable = bgImage && self.parallaxEnabled;
	
	_bgImage = bgImage;
}
- (UIImage *)image {
	return self.bgImageView.image;
}
- (void)setParallaxAvailable:(BOOL)parallaxAvailable {
	_parallaxAvailable = parallaxAvailable;
	if (parallaxAvailable) {
		[self updateParallax];
		self.bgImageViewHeightConstraint.constant = FFEventImageTitleCellHeight + 2 * MAX_PARALLAX_OFFSET;
	} else {
		self.bgImageViewCenterConstraint.constant = 0;
		self.bgImageViewHeightConstraint.constant = FFEventImageTitleCellHeight;
	}
	[self layoutIfNeeded];
//	[self.titleBackground updateBlur];
}
- (void)updateWithScrollPercentage:(float)percent {
//	if (percent > 1) percent = 1;
//	else if (percent < 0) percent = 0;
	self.parallaxPercent = percent - .5f;
}
- (void)setParallaxPercent:(float)parallaxPercent {
	_parallaxPercent = parallaxPercent;
	[self updateParallax];
}
- (void)updateParallax {
	if (!self.parallaxAvailable) return;
	self.bgImageViewCenterConstraint.constant = MAX_PARALLAX_OFFSET * self.parallaxPercent;
	
}
/*
+ (NSString *)eventDescription:(Event *)event {
	NSString * detailsString;
	NSMutableArray * details = [NSMutableArray array];
	if (event.countries.length) [details addObject:event.countries];
	if (event.year.intValue)	[details addObject:event.year];
	if (event.runTime)			[details addObject:[NSString stringWithFormat:@"%@ mins", event.runTime]];
	if (details.count) {
		detailsString = [NSString stringWithFormat:@" (%@)", [details componentsJoinedByString:@", "]];
	} else {
		detailsString = @"";
	}
	return [NSString stringWithFormat:@"%@%@", event.sectionName, detailsString];
}
 */
- (IBAction)heartButtonTap:(id)sender {
	self.isFavorite = !self.isFavorite;
}
- (void)setIsFavorite:(BOOL)isFavorite {
	self.heartButton.selected = isFavorite;
	__weak FFEventImageTitleCell * weakself = self;
	
	[MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
		weakself.event.isFavorite = [NSNumber numberWithBool:isFavorite];
	} completion:^(BOOL success, NSError *error) {
		if (weakself.onFavoriteChange) {
			weakself.onFavoriteChange(isFavorite);
		}
	}];
	
	/*
	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
		weakself.event.isFavorite = [NSNumber numberWithBool:isFavorite];
	} completion:^(BOOL success, NSError *error) {
		if (weakself.onFavoriteChange) {
			weakself.onFavoriteChange(isFavorite);
		}
	}];
	 */
	_isFavorite = isFavorite;
}
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
	void (^changeValuesBlock)() = ^() {
		self.highlightView.hidden = !highlighted;
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
