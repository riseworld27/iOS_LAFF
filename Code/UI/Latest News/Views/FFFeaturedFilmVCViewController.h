//
//  FFFeaturedFilmVCViewController.h
//  laff
//
//  Created by matata on 16.03.15.
//  Copyright (c) 2015 matata. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Event.h"

extern NSString * const FFFeaturedFilmVCViewControllerIdentifier;

typedef void (^FFFeaturedFilmVCViewControllerFavoriteChanged)(BOOL isFavorite);

@interface FFFeaturedFilmVCViewController : UIViewController

@property (nonatomic, strong) Event * event;

@property (nonatomic, assign, readonly) BOOL heartButtonPressing;

@property (nonatomic, strong) FFFeaturedFilmVCViewControllerFavoriteChanged onFavoriteChange;

- (void)updateStatuses;

@end
