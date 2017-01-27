//
//  FFFeaturedFilmSwipeCell.m
//  laff
//
//  Created by matata on 16.03.15.
//  Copyright (c) 2015 matata. All rights reserved.
//

#import "FFFeaturedFilmSwipeCell.h"
#import "FFFeaturedFilmVCViewController.h"
#import "FFConstants.h"

#import "UIStoryboard+Main.h"
#import "UIColor+RGB.h"
#import "NSMutableArray+Shuffling.h"

#import <SwipeView/SwipeView.h>
#import <Lyt/Lyt.h>

NSString * const FFFeaturedFilmSwipeCellIdentifier = @"featured films";
CGFloat const FFFeaturedFilmSwipeCellHeight = 230.f;

@interface FFFeaturedFilmSwipeCell () <SwipeViewDataSource, SwipeViewDelegate>

@property (weak, nonatomic) IBOutlet SwipeView *swipeView;
//@property (weak, nonatomic) IBOutlet UIImageView *rightArrowImageView;
//@property (weak, nonatomic) IBOutlet UIImageView *leftArrowImageView;
@property (weak, nonatomic) IBOutlet UIButton *rightArrowButton;
@property (weak, nonatomic) IBOutlet UIButton *leftArrowButton;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;

@property (nonatomic, strong) NSMutableArray * controllers;
@property (nonatomic, strong) NSArray * featuredEvents;

//@property (nonatomic, strong) UIView * highlightView;

@property (nonatomic, strong) UIActivityIndicatorView * loadingIndicator;

@end

@implementation FFFeaturedFilmSwipeCell

- (void)awakeFromNib {
	self.headerLabel.textColor = [UIColor colorFromRGB:FFConstantTintColor];
	
	self.clipsToBounds = YES;
	
	UIImage * originalImage = self.leftArrowButton.imageView.image;
	UIImage * mirroredImage = [UIImage imageWithCGImage:originalImage.CGImage scale:originalImage.scale orientation:UIImageOrientationUpMirrored];
	[self.leftArrowButton setImage:mirroredImage forState:UIControlStateNormal];
	
//	self.leftArrowImageView.image = [UIImage imageWithCGImage:self.leftArrowImageView.image.CGImage scale:self.leftArrowImageView.image.scale orientation:UIImageOrientationUpMirrored];
	
	self.swipeView.delegate = self;
	self.swipeView.dataSource = self;
	
	/*
	self.highlightView = [[UIView alloc] initWithFrame:self.bounds];
	self.highlightView.backgroundColor = [UIColor colorFromRGB:FFConstantTintColor andAlpha:.4f];
	self.highlightView.hidden = YES;
	[self.contentView insertSubview:self.highlightView aboveSubview:self.swipeView];
	 */
	
	self.swipeView.backgroundColor = [UIColor blackColor];
	
	self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = NO;
	[self.loadingIndicator startAnimating];
	[self.contentView addSubview:self.loadingIndicator];
	[self.loadingIndicator lyt_centerInParent];
	
	[self updateArrowsVisibilityWithCurrentIndex:0];
}
- (void)initWithFeaturedEvents:(NSArray *)featuredEvents {
	NSMutableArray * shuffledEvents = [NSMutableArray arrayWithArray:featuredEvents];
	[shuffledEvents shuffle];
	self.featuredEvents = shuffledEvents;
	
	self.controllers = [NSMutableArray arrayWithCapacity:self.featuredEvents.count];
	for (uint i = 0; i < self.featuredEvents.count; i++) {
		[self.controllers addObject:[NSNull null]];
	}
	
	[self.loadingIndicator removeFromSuperview];
	self.loadingIndicator = nil;
	
	[self.swipeView reloadData];
	[self.swipeView updateConstraints];
	
	[self updateArrowsVisibilityWithCurrentIndex:0];
}

//////////////////////////////////////////////////
#pragma mark - Update
//////////////////////////////////////////////////

- (void)updateStatuses {
	FFFeaturedFilmVCViewController * featuredFilm = self.controllers[self.swipeView.currentItemIndex];
	[featuredFilm updateStatuses];
}

//////////////////////////////////////////////////
#pragma mark - Swipe view data source and delegate
//////////////////////////////////////////////////

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView {
	return self.featuredEvents ? self.featuredEvents.count : 0;
}
- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
	
	FFFeaturedFilmVCViewController * featuredFilm = self.controllers[index];
	BOOL alreadyInstantiated = featuredFilm != (id)[NSNull null];

	if (!alreadyInstantiated) {
		featuredFilm = [[UIStoryboard mainStoryboard] instantiateViewControllerWithIdentifier:FFFeaturedFilmVCViewControllerIdentifier];
		self.controllers[index] = featuredFilm;
		
		featuredFilm.event = self.featuredEvents[index];
		featuredFilm.view.backgroundColor = [UIColor orangeColor];
		featuredFilm.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 180);
	}
	
	return featuredFilm.view;
}
- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView {
		NSLog(@"swipeViewCurrentItemIndexDidChange: %d", (int)swipeView.currentItemIndex);
	[self updateArrowsVisibilityWithCurrentIndex:swipeView.currentItemIndex];
}
- (void)swipeView:(SwipeView *)swipeView didSelectItemAtIndex:(NSInteger)index {
	if (self.onSelect) {
		self.onSelect();
	}
}

//////////////////////////////////////////////////
#pragma mark - Arrows
//////////////////////////////////////////////////

- (IBAction)leftArrowPress:(id)sender {
	[self.swipeView scrollByNumberOfItems:-1 duration:.3f];
}
- (IBAction)rightArrowPress:(id)sender {
	[self.swipeView scrollByNumberOfItems:1 duration:.3f];
}
- (void)updateArrowsVisibilityWithCurrentIndex:(NSUInteger)currentIndex {
//	self.leftArrowImageView.hidden = !currentIndex;
//	self.rightArrowImageView.hidden = currentIndex == self.featuredEvents.count - 1;
	
	self.leftArrowButton.hidden = !currentIndex;
	self.rightArrowButton.hidden = self.featuredEvents.count <= 1 || currentIndex == self.featuredEvents.count - 1;
}

//////////////////////////////////////////////////
#pragma mark - Getters
//////////////////////////////////////////////////

- (Event *)currentEvent {
	return self.featuredEvents[self.swipeView.currentItemIndex];
}

/*
//////////////////////////////////////////////////
#pragma mark - Highlight / select
//////////////////////////////////////////////////

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
	NSLog(@"set highlighted: %u", highlighted);
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
 */

@end
