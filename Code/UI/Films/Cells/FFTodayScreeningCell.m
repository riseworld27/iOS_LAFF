//
//  FFTodayScreeningCell.m
//  laff
//
//  Created by matata on 2.05.14.
//  Copyright (c) 2014 matata. All rights reserved.
//

#import "FFTodayScreeningCell.h"
#import "Event.h"
#import <MTDates/NSDate+MTDates.h>
#import "FFDateUtils.h"

NSString * const FFTodayScreeningCellIdentifier = @"Today screening";
CGFloat const FFTodayScreeningCellHeight = 44.f;

@interface FFTodayScreeningCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeDayPartLabel;

@end

@implementation FFTodayScreeningCell

- (void)setScreening:(Screening *)screening {
	Event * event = screening.event;
	
	self.titleLabel.text = event.eventTitle;
	self.locationLabel.text = screening.venueName;
	
//	self.timeLabel.text = [NSString stringWithFormat:@"%d:%.2d", (uint)[screening.screeningDate mt_hourOfDay], (uint)[screening.screeningDate mt_minuteOfHour]];
	self.timeLabel.text = [[FFDateUtils screeningCalendarTimeFormatter] stringFromDate:screening.screeningDate];
	
	self.timeDayPartLabel.text = [screening.screeningDate mt_isInAM] ? @"AM" : @"PM";
	
	_screening = screening;
}

@end
