//
//  PDDateUtils.m
//  ParseDemo
//
//  Created by matata on 23.04.14.
//  Copyright (c) 2014 matata. All rights reserved.
//

#import "FFDateUtils.h"
#import <MTDates/NSDate+MTDates.h>

@implementation FFDateUtils

+ (NSDate *)screeningDateWithDateString:(NSString *)dateString andTimeString:(NSString *)timeString {
	NSString * completeString = [NSString stringWithFormat:@"%@ %@", dateString, timeString];
	NSDate * final = [[FFDateUtils rawScreeningFormatter] dateFromString:completeString];
	
//	NSDate * date = [[FFDateUtils rawScreeningDateFormatter] dateFromString:dateString];
//	NSDate * time = [[FFDateUtils rawScreeningTimeFormatter] dateFromString:timeString];
//	NSDate * final = [NSDate mt_dateFromYear:date.mt_year month:date.mt_monthOfYear day:date.mt_dayOfMonth hour:time.mt_hourOfDay minute:time.mt_minuteOfHour];
//	NSDate * final = [date dateByAddingTimeInterval:[time timeIntervalSince1970]];
	
//	NSLog(@"date: %@, time: %@, final: %@", dateString, timeString, final);
	return final;
}
+ (NSDateFormatter *)rawScreeningFormatter {
	static NSDateFormatter * dateFormatter;
	if (!dateFormatter) {
		dateFormatter = [NSDateFormatter new];
		dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
		dateFormatter.timeZone = [FFDateUtils timezone];
	}
	return dateFormatter;
}
+ (NSDateFormatter *)screeningDateFormatter {
	static NSDateFormatter * dateFormatter;
	if (!dateFormatter) {
		NSString * dateFormat = [NSDateFormatter dateFormatFromTemplate:@"EEE, MMM d, HH:mm a" options:0 locale:[NSLocale currentLocale]];
		dateFormatter = [NSDateFormatter new];
		dateFormatter.dateFormat = dateFormat;
		dateFormatter.timeZone = [FFDateUtils timezone];
	}
	return dateFormatter;
}
/*
+ (NSDateFormatter *)rawScreeningTimeFormatter {
	static NSDateFormatter * dateFormatter;
	if (!dateFormatter) {
		dateFormatter = [NSDateFormatter new];
		dateFormatter.dateFormat = @"HH:mm";
		dateFormatter.timeZone = [NSTimeZone systemTimeZone];
	}
	return dateFormatter;
}
+ (NSDateFormatter *)rawScreeningDateFormatter {
	static NSDateFormatter * dateFormatter;
	if (!dateFormatter) {
		dateFormatter = [NSDateFormatter new];
		dateFormatter.dateFormat = @"yyyy-MM-dd";
		dateFormatter.timeZone = [NSTimeZone systemTimeZone];
	}
	return dateFormatter;
}
 */
/*
+ (NSDateFormatter *)rawTweetDateFormatter {
	static NSDateFormatter * dateFormatter;
	if (!dateFormatter) {
		dateFormatter = [NSDateFormatter new];
		dateFormatter.dateFormat = @"EEE MMM dd HH:mm:ss Z yyyy";
	}
	return dateFormatter;
}
*/
+ (NSDateFormatter *)screeningScheduleDateFormatter {
	static NSDateFormatter * dateFormatter;
	if (!dateFormatter) {
//		NSString * dateFormat = [NSDateFormatter dateFormatFromTemplate:@"eeee MMMM d 'at' j:mm" options:0 locale:[NSLocale currentLocale]];
		dateFormatter = [NSDateFormatter new];
		dateFormatter.timeZone = [FFDateUtils timezone];
		dateFormatter.dateFormat = @"eeee MMMM d 'at' h:mm a";
	}
	return dateFormatter;
}
+ (NSDateFormatter *)screeningCalendarTimeFormatter {
	static NSDateFormatter * dateFormatter;
	if (!dateFormatter) {
		dateFormatter = [NSDateFormatter new];
		dateFormatter.timeZone = [FFDateUtils timezone];
		dateFormatter.dateFormat = @"h:mm";
	}
	return dateFormatter;
}
+ (NSTimeZone *)timezone {
	static NSTimeZone * timezone;
	if (!timezone) {
		timezone = [NSTimeZone timeZoneForSecondsFromGMT:0];
	}
	return timezone;
}

@end
