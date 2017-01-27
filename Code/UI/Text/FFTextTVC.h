//
//  FFTextTVC.h
//  laff
//
//  Created by matata on 19.05.14.
//  Copyright (c) 2014 matata. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const FFTextTVCIdentifier;

@interface FFTextTVC : UITableViewController

@property (nonatomic, strong) NSString * text;
@property (nonatomic, strong) NSAttributedString * atext;

@end
