//
//  FFWeekCell.m
//  laff
//
//  Created by matata on 1.05.14.
//  Copyright (c) 2014 matata. All rights reserved.
//

#import "FFWeekCell.h"
#import "FFEventsManager.h"
#import "FFWeekDay.h"

#import "UIColor+RGB.h"

#import <MTDates/NSDate+MTDates.h>
#import <Lyt/Lyt.h>

NSString * const FFWeekCellIdentifier = @"Week";
CGFloat const FFWeekCellHeight = 98.f;

//static CGFloat const DAY_WIDTH = 44.f;
//static CGFloat const DAY_SPACE = 2.f;

@interface FFWeekCell ()

@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
@property (weak, nonatomic) IBOutlet UIButton *todayButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightOffset;

@property (nonatomic, strong) FFEventsManager * eventsManager;
@property (nonatomic, strong) NSDate * firstScreeningDate;
@property (nonatomic, strong) NSDate * lastScreeningDate;
@property (nonatomic, strong) NSDate * firstVisibleDate;
@property (nonatomic, strong) NSDate * lastVisibleDate;
@property (nonatomic, assign) NSInteger numDays;
@property (nonatomic, assign) NSInteger numWeeks;
@property (nonatomic, strong) NSDate * today;

@property (nonatomic, strong) NSMutableArray * days;
@property (nonatomic, strong) FFWeekDay * selectedDay;

@property (nonatomic, assign) NSUInteger currentPage;

@property (nonatomic, strong) NSMutableArray * userConstraints;

@end

@implementation FFWeekCell

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		self.eventsManager = [FFEventsManager instance];
//		[self initDates];
	}
	return self;
}
/**
 * method should be called from outside to make sure cell frame is already correct
 */
- (void)initDates {
	[self initDatesForMySchedule:NO];
}
- (void)initDatesForMySchedule:(BOOL)useMySchedule {
	if (self.today) return;
	
	if (useMySchedule) {
		self.firstScreeningDate = self.eventsManager.firstMyScreeningDate;
		self.lastScreeningDate  = self.eventsManager.lastMyScreeningDate;
	} else {
		self.firstScreeningDate = self.eventsManager.firstScreeningDate;
		self.lastScreeningDate  = self.eventsManager.lastScreeningDate;
	}
	self.firstVisibleDate = [self.firstScreeningDate mt_startOfCurrentWeek];
	self.lastVisibleDate = [self.lastScreeningDate mt_endOfCurrentWeek];
	self.numDays = [self.lastVisibleDate mt_daysSinceDate:self.firstVisibleDate] + 1;
	self.numWeeks = (NSInteger)ceilf((float)self.numDays / 7.f);
//	self.numDays = MIN(70, [self.lastVisibleDate mt_daysSinceDate:self.firstVisibleDate] + 1);
//	self.numWeeks = MIN(10, (NSInteger)ceilf((float)self.numDays / 7.f));
	
//	self.today = [self.firstScreeningDate mt_dateDaysAfter:100];
//	self.today = [self.firstScreeningDate mt_dateDaysAfter:1];
//	self.today = [self.firstScreeningDate mt_dateDaysAfter:7];
//	self.today = [self.firstScreeningDate mt_dateDaysBefore:1];
	
	self.today = [NSDate mt_startOfToday];
	
	NSLog(@"self.firstScreeningDate: %@", self.firstScreeningDate);
	NSLog(@"self.lastScreeningDate: %@", self.lastScreeningDate);
	NSLog(@"self.firstVisibleDate: %@", self.firstVisibleDate);
	NSLog(@"self.lastVisibleDate: %@", self.lastVisibleDate);
	NSLog(@"self.numDays: %d", (int)self.numDays);
	NSLog(@"self.numWeeks: %d", (int)self.numWeeks);
	
	[self addDays];
}
- (void)awakeFromNib {
	self.todayButton.layer.masksToBounds = YES;
	self.todayButton.layer.cornerRadius = 3.f;
	
	self.scrollView.scrollsToTop = NO;
	self.scrollView.clipsToBounds = NO;
}
- (void)prepareForReuse {
	self.today = nil;
	
	/*
	for (NSLayoutConstraint * constraint in self.userConstraints) {
		[constraint.firstItem removeConstraint:constraint];
	}
	 */
//	[self.userConstraints removeAllObjects];
	
//	[self.scrollView removeConstraints:self.scrollView.constraints];
	if (self.days) {
		for (FFWeekDay * day in self.days) {
//			[day removeConstraints:day.constraints];
			[day removeFromSuperview];
		}
//		[self.days makeObjectsPerformSelector:@selector(removeFromSuperview)];
		self.days = nil;
	}
	
//	[self.contentView.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
	
	_selectedDay = nil;
	_currentPage = 0;
	
	self.onDayChange = nil;
}
- (void)addDays {
	NSAssert(!self.days, @"Should not have days at this point");
	
	if (!self.tableWidth) {
		self.tableWidth = CGRectGetWidth(self.scrollView.frame);
	}
	
	self.userConstraints = [NSMutableArray array];
	
	CALayer * hairline = [CALayer layer];
	hairline.frame = CGRectMake(0.f, 60.f, self.tableWidth, .5f);
	hairline.backgroundColor = [UIColor colorFromRGB:0xe6e7e9].CGColor;
	[self.contentView.layer insertSublayer:hairline atIndex:0];
	
	static CGFloat dayWidth = 44.f;
	CGFloat daySpace = (self.tableWidth - 7 * dayWidth) / 8;
	self.rightOffset.constant = daySpace;
	
	//// w = x*a + y*b
	//// b = ?
	//// x = 7
	//// y = x+1
	//// w = 375
	//// b = (w - x*a) / y
	//// b = (w - x*a) / x+1
	//// b = (w - 7*a) / 7+1
	
	__weak FFWeekCell * weakself = self;
	
	FFWeekDay * day, * prevDay;
	
	self.days = [NSMutableArray arrayWithCapacity:self.numDays];
	NSDate * currentDay = self.firstVisibleDate.copy;
	for (uint i = 0; i < self.numDays; i++) {
		day = [[[NSBundle mainBundle] loadNibNamed:@"FFWeekDay" owner:nil options:nil] firstObject];
		
		/*
		//// Position
		CGRect dayFrame = day.frame;
		dayFrame.origin.x = i * (DAY_WIDTH + DAY_SPACE);
		NSLog(@"dayFrame: %@", NSStringFromCGRect(dayFrame));
		day.frame = dayFrame;
		 */
		
		//// Data
		day.date = currentDay.copy;
		if ([currentDay mt_isWithinSameDay:self.today]) {
			day.timeType = FFWeekDayTimeTypeToday;
			day.selected = YES;
			self.selectedDay = day;
		} else if ([currentDay mt_isAfter:self.today]) {
			day.timeType = FFWeekDayTimeTypeInFuture;
		} else {
			day.timeType = FFWeekDayTimeTypeInPast;
		}
		
		currentDay = [currentDay mt_oneDayNext];
		
		//// Callback
		__weak FFWeekDay * weakday = day;
		day.onPress = ^() {
			weakself.selectedDay = weakday;
			[weakself setTodayButtonEnabled:(weakday.timeType != FFWeekDayTimeTypeToday)];
		};
		
		self.days[i] = day;
		[self.scrollView addSubview:day];
		
		day.translatesAutoresizingMaskIntoConstraints = NO;
		[self.userConstraints addObject:[day lyt_alignTopToParent]];
		[self.userConstraints addObject:[day lyt_setHeight:64.f]];
		[self.userConstraints addObject:[day lyt_setWidth:dayWidth]];
		if (prevDay) {
			[self.userConstraints addObject:[day lyt_placeRightOfView:prevDay margin:daySpace]];
		} else {
			[self.userConstraints addObject:[day lyt_alignLeftToParentWithMargin:daySpace]];
		}
		
		prevDay = day;
	}
	[self.userConstraints addObject:[day lyt_alignRightToParentWithMargin:daySpace]];
	
	self.scrollView.contentSize = CGSizeMake(self.numWeeks * CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
	self.scrollView.delegate = self;
}
- (BOOL)todayIsWithinRange {
	return [self.today mt_isOnOrAfter:self.firstVisibleDate] && [self.today mt_isOnOrBefore:self.lastVisibleDate];
}
- (void)selectActualDay {
	BOOL todayIsAfterFirstDay = [self.today mt_isOnOrAfter:self.firstVisibleDate];
	BOOL todayIsBeforeLastDay = [self.today mt_isOnOrBefore:self.lastVisibleDate];
	if (todayIsAfterFirstDay && todayIsBeforeLastDay) {
		[self makeTodayVisible];
	} else if (todayIsBeforeLastDay) {
		// Before festival
		self.currentPage = 0;
		self.todayButton.hidden = YES;
		[self selectDate:self.firstScreeningDate];
	} else if (todayIsAfterFirstDay) {
		// After festival
		self.currentPage = self.numWeeks - 1;
		self.todayButton.hidden = YES;
		[self selectDate:self.lastScreeningDate];
	}
}
- (void)selectDate:(NSDate *)date {
	NSUInteger dayIndex = [date mt_daysSinceDate:self.firstVisibleDate];
	FFWeekDay * day = self.days[dayIndex];
	self.selectedDay = day;
	self.currentPage = dayIndex / 7;
}
- (void)setTodayButtonEnabled:(BOOL)enabled {
	self.todayButton.enabled = enabled;
	self.todayButton.alpha = enabled ? 1.f : .35f;
}
- (IBAction)todayButtonPress:(UIButton *)sender {
	[self makeTodayVisible];
}
- (void)makeTodayVisible {
	[self selectDate:self.today];
	[self setTodayButtonEnabled:NO];
}
- (void)setSelectedDay:(FFWeekDay *)selectedDay {
	if (_selectedDay) {
		_selectedDay.selected = NO;
	}
	_selectedDay = selectedDay;
	_selectedDay.selected = YES;
	if (self.onDayChange) {
		self.onDayChange(selectedDay.date);
	}
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	self.currentPage = self.scrollView.contentOffset.x / CGRectGetWidth(self.scrollView.frame);
}
- (void)setCurrentPage:(NSUInteger)currentPage {
	NSDate * firstDayOnPage = [self.firstVisibleDate mt_dateDaysAfter:currentPage * 7];
	NSDate * lastDayOnPage = [self.firstVisibleDate mt_dateDaysAfter:(currentPage + 1) * 7 - 1];
	NSUInteger pageStartMonth = [firstDayOnPage mt_monthOfYear];
	NSUInteger pageEndMonth = [lastDayOnPage mt_monthOfYear];
	if (pageStartMonth == pageEndMonth) {
		[self updateMonthWithNumber:pageStartMonth];
	} else {
		[self updateMonthWithStart:pageStartMonth end:pageEndMonth];
	}
	
	CGFloat scrollOffsetX = CGRectGetWidth(self.scrollView.frame) * currentPage;
	if (scrollOffsetX != self.scrollView.contentOffset.x) {
		[self.scrollView setContentOffset:CGPointMake(scrollOffsetX, 0) animated:YES];
	}
	
	_currentPage = currentPage;
}
- (void)updateMonthWithNumber:(NSUInteger)monthNum {
	self.monthLabel.text = [NSDate mt_monthlySymbols][monthNum - 1];
}
- (void)updateMonthWithStart:(NSUInteger)startMonthNum end:(NSUInteger)endMonthNum {
	self.monthLabel.text = [NSString stringWithFormat:@"%@ - %@", [NSDate mt_monthlySymbols][startMonthNum - 1], [NSDate mt_monthlySymbols][endMonthNum - 1]];
}

@end
