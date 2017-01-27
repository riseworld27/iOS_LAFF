//
//  FFCoverImageVC.m
//  laff
//
//  Created by matata on 19.05.14.
//  Copyright (c) 2014 matata. All rights reserved.
//

#import "FFCoverImageVC.h"
#import "GA.h"

#import <SDiPhoneVersion/SDiPhoneVersion.h>

@interface FFCoverImageVC ()

@end

@implementation FFCoverImageVC

- (void)viewDidLoad {
    [super viewDidLoad];
	
	/*
	CGSize screenSize = [UIScreen mainScreen].bounds.size;
	NSString * launchImageName = [NSString stringWithFormat:@"LaunchImage-Portrait{%.0f,%.0f}@2x.png", screenSize.width, screenSize.height];
	
	UIImageView * launchImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:launchImageName]];
	
//	CGSize screenSize = [UIScreen mainScreen].bounds.size;
//	BOOL is4inch = screenSize.height >= 568.f;
//	UIImage * launchImage = [UIImage imageNamed:is4inch ? @"LaunchImage-700-568h" : @"LaunchImage-700"];
//	UIImageView * launchImageView = [[UIImageView alloc] initWithImage:launchImage];
	
	[self.view addSubview:launchImageView];
	 */
	
	NSString * splashScreenNibName;
#ifdef LAFF
	splashScreenNibName = @"LAFF Launch Screen";
	
	UIImage * launchImage;
	
	DeviceSize phoneSize = [SDiPhoneVersion deviceSize];
	switch (phoneSize) {
		case iPhone55inch:
			launchImage = [UIImage imageNamed:@"LaunchImage-800-Portrait-736h"];
			break;
		case iPhone47inch:
			launchImage = [UIImage imageNamed:@"LaunchImage-800-667h"];
			break;
		case iPhone4inch:
			launchImage = [UIImage imageNamed:@"LaunchImage-700-568h"];
			break;
		case iPhone35inch:
			launchImage = [UIImage imageNamed:@"LaunchImage-700"];
			break;
		default:
			break;
	}
	
	if (launchImage) {
		[self.view addSubview:[[UIImageView alloc] initWithImage:launchImage]];
	}
	
#elif NBFF
	splashScreenNibName = @"NBFF Launch Screen";
	
	UIView * splashScreenView = [[[NSBundle mainBundle] loadNibNamed:splashScreenNibName owner:nil options:nil] firstObject];
	splashScreenView.frame = self.view.bounds;
	[self.view addSubview:splashScreenView];
#endif
	
}
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
	[tracker set:kGAIScreenName value:@"Cover Image screen"];
	[tracker send:[[GAIDictionaryBuilder createAppView] build]];
}
- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
