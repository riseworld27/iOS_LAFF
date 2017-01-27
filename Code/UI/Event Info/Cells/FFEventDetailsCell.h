//
//  FFEventDetailsCell.h
//  laff
//
//  Created by matata on 30.04.14.
//  Copyright (c) 2014 matata. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const FFEventDetailsCellIdentifier;
extern CGFloat const FFEventDetailsCellHeight;
extern CGFloat const FFEventDetailsCellHeightNoText;

@interface FFEventDetailsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *cellTitle;
@property (weak, nonatomic) IBOutlet UILabel *cellDescription;

@end
