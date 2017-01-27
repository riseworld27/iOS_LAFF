//
//  FFFeaturedFilmVCViewController.m
//  laff
//
//  Created by matata on 16.03.15.
//  Copyright (c) 2015 matata. All rights reserved.
//

#import "FFFeaturedFilmVCViewController.h"

#import "Event+Description.h"

#import <MagicalRecord/CoreData+MagicalRecord.h>
#import <AFNetworking/UIImageView+AFNetworking.h>

NSString * const FFFeaturedFilmVCViewControllerIdentifier = @"featured film";

@interface FFFeaturedFilmVCViewController ()

@property (weak, nonatomic) IBOutlet UIButton *heartButton;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (nonatomic, assign) BOOL isFavorite;

@property (nonatomic, strong) UIImage * bgImage;
@property (nonatomic, strong) NSDate * imageLoadingStartTime;

@end

@implementation FFFeaturedFilmVCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	[self showEvent];
}
- (IBAction)heartButtonTap:(id)sender {
	_heartButtonPressing = NO;
	self.isFavorite = !self.isFavorite;
}
- (IBAction)heartButtonTouchDown:(id)sender {
	_heartButtonPressing = YES;
}
- (IBAction)heartButtonReleaseOutside:(id)sender {
	_heartButtonPressing = NO;
}
- (void)setIsFavorite:(BOOL)isFavorite {
	self.heartButton.selected = isFavorite;
	
	[MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
		self.event.isFavorite = [NSNumber numberWithBool:isFavorite];
	} completion:^(BOOL success, NSError *error) {
		if (self.onFavoriteChange) {
			self.onFavoriteChange(isFavorite);
		}
	}];
	
	_isFavorite = isFavorite;
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
//	self.parallaxAvailable = bgImage && self.parallaxEnabled;
	
	_bgImage = bgImage;
}
- (void)showEvent {
//	self.parallaxAvailable = NO;
	self.bgImage = nil;
	
	self.titleLabel.text = self.event.eventTitle;
	
	_isFavorite = [self.event.isFavorite boolValue];
	self.heartButton.selected = _isFavorite;
	
	self.descriptionLabel.text = self.event.description;
	
	NSURL * imageURL = [NSURL URLWithString:self.event.filmImageURL];
	if (imageURL) {
		NSURLRequest * request = [NSURLRequest requestWithURL:imageURL];
		UIImage * placeholder = self.placeholderImage;
		self.imageLoadingStartTime = [NSDate new];
		[self.bgImageView setImageWithURLRequest:request placeholderImage:placeholder success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			self.bgImage = image;
		} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
			self.bgImage = nil;
		}];
	}
}

//////////////////////////////////////////////////
#pragma mark - Update
//////////////////////////////////////////////////

- (void)updateStatuses {
	self.isFavorite = self.event.isFavorite.boolValue;
}

@end
