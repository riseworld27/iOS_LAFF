//
//  PDEventsManager.h
//  ParseDemo
//
//  Created by matata on 23.04.14.
//  Copyright (c) 2014 matata. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const FFEventsManagerStateChanged;

typedef NS_ENUM(NSUInteger, FFEventsManagerState) {
    FFEventsManagerStateNotInited = 0,
    FFEventsManagerStateNoData,				// 1
    FFEventsManagerStateNoDataAndLoading,	// 2
	FFEventsManagerStateHasData,			// 3
	FFEventsManagerStateHasDataAndUpdating, // 4
};

@interface FFEventsManager : NSObject

@property (nonatomic, assign, readonly) FFEventsManagerState state;

@property (nonatomic, weak, readonly) NSArray * events;
@property (nonatomic, weak, readonly) NSArray * screeningsSortedByDate;
- (NSArray *)upcomingScreeningsLimitedBy:(NSUInteger)numScreenings;
- (NSArray *)screeningsSortedByDateWithTextInTitle:(NSString *)searchText;
@property (nonatomic, weak, readonly) NSArray * favoriteEvents;
- (BOOL)hasFeaturedEvents;
@property (nonatomic, weak, readonly) NSArray * featuredEvents;
- (NSArray *)  screeningsOnDay:(NSDate *)date;
- (NSArray *)myScreeningsOnDay:(NSDate *)date;
@property (nonatomic, weak, readonly) NSDate * firstScreeningDate;
@property (nonatomic, weak, readonly) NSDate * lastScreeningDate;
@property (nonatomic, weak, readonly) NSDate * firstMyScreeningDate;
@property (nonatomic, weak, readonly) NSDate * lastMyScreeningDate;
- (BOOL)hasMyScreenings;

+ (instancetype)instance;

- (void)load;
- (void)deleteAllSynchronous:(BOOL)synchronous;

@end
