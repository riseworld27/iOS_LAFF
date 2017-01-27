//
//  FFWeekDay.h
//  laff
//
//  Created by matata on 2.05.14.
//  Copyright (c) 2014 matata. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, FFWeekDayTimeType) {
    FFWeekDayTimeTypeInPast,
    FFWeekDayTimeTypeToday,
    FFWeekDayTimeTypeInFuture,
};

typedef void (^FFWeekDayPressed)();

@interface FFWeekDay : UIView

@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UIButton *dateButton;

@property (nonatomic, strong) NSDate * date;
@property (nonatomic, assign) FFWeekDayTimeType timeType;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, strong) FFWeekDayPressed onPress;

@end
