//
//  FFEventActionsCell.h
//  laff
//
//  Created by matata on 20.03.15.
//  Copyright (c) 2015 matata. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Event.h"

extern NSString * const FFEventActionsCellIdentifier;
extern CGFloat const FFEventActionsCellHeight;

typedef void (^FFEventActionsCellFavoriteChanged)(BOOL isFavorite);

@interface FFEventActionsCell : UITableViewCell

@property (nonatomic, strong) Event * event;
@property (nonatomic, copy) emptyBlock onAddToCart;
@property (nonatomic, strong) FFEventActionsCellFavoriteChanged onFavoriteChange;

@end
