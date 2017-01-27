//
//  SVBlurView.h
//  SVBlurView
//
//  Created by matata on 19.10.13.
//  Copyright (c) 2013 matata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SVBlurView : UIView

@property (nonatomic, readwrite) CGFloat blurRadius; // default is 20.0f
@property (nonatomic, readwrite) CGFloat saturationDelta; // default is 1.5
@property (nonatomic, readwrite) UIColor *tintColor; // default nil
@property (nonatomic, weak) UIView *viewToBlur; // default is superview

- (void)updateBlur;

@end
