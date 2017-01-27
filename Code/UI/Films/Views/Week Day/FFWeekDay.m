//
//  FFWeekDay.m
//  laff
//
//  Created by matata on 2.05.14.
//  Copyright (c) 2014 matata. All rights reserved.
//

#import "FFWeekDay.h"
#import <MTDates/NSDate+MTDates.h>
#import "UIColor+RGB.h"

@implementation FFWeekDay

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (IBAction)weekdayTap:(id)sender {
	if (self.onPress) {
		self.onPress();
	}
}
- (void)setDate:(NSDate *)date {
	NSUInteger dateOfWeek = (date.mt_weekdayOfWeek + ((NSCalendar *)[NSCalendar currentCalendar]).firstWeekday - 2) % 7;
	self.dayLabel.text = [NSDate mt_veryShortWeekdaySymbols][dateOfWeek];
	NSString * dayNumberString = [NSString stringWithFormat:@"%d", (uint)[date mt_dayOfMonth]];
	[self.dateButton setTitle:dayNumberString forState:UIControlStateNormal];
	_date = date;
}
- (void)updateUI {
	if (self.selected) {
		NSString * imageName;
		if (self.timeType == FFWeekDayTimeTypeToday) {
#ifdef LAFF
			imageName = @"laff_weekday_bg_today_selected";
#elif NBFF
			imageName = @"nbff_weekday_bg_today_selected";
#endif
		} else {
#ifdef LAFF
			imageName = @"laff_weekday_bg_selected";
#elif NBFF
			imageName = @"nbff_weekday_bg_selected";
#endif
		}
		[self.dateButton setBackgroundImage:[[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
		[self.dateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	} else {
		switch (self.timeType) {
			case FFWeekDayTimeTypeInPast:
				[self.dateButton setBackgroundImage:nil forState:UIControlStateNormal];
				[self.dateButton setTitleColor:[UIColor colorFromRGB:0xbbbbbb] forState:UIControlStateNormal];
				break;
			case FFWeekDayTimeTypeToday:
				[self.dateButton setBackgroundImage:[[UIImage imageNamed:@"weekday_bg_today"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
				[self.dateButton setTitleColor:[UIColor colorFromRGB:0x717171] forState:UIControlStateNormal];
				break;
			case FFWeekDayTimeTypeInFuture:
				[self.dateButton setBackgroundImage:nil forState:UIControlStateNormal];
				[self.dateButton setTitleColor:[UIColor colorFromRGB:0x717171] forState:UIControlStateNormal];
				break;
		}
	}
	self.userInteractionEnabled = !self.selected;
}
- (void)setTimeType:(FFWeekDayTimeType)timeType {
	_timeType = timeType;
	[self updateUI];
}
- (void)setSelected:(BOOL)selected {
	_selected = selected;
	[self updateUI];
}

@end
