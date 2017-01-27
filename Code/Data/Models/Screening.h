//
//  Screening.h
//  laff
//
//  Created by matata on 12.04.15.
//  Copyright (c) 2015 matata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event;

@interface Screening : NSManagedObject

@property (nonatomic, retain) NSString * displayDate;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSNumber * isSaved;
@property (nonatomic, retain) NSDate * screeningDate;
@property (nonatomic, retain) NSNumber * sequence;
@property (nonatomic, retain) NSString * ticketDesc;
@property (nonatomic, retain) NSDecimalNumber * ticketPrice;
@property (nonatomic, retain) NSNumber * ticketType;
@property (nonatomic, retain) NSString * venueCode;
@property (nonatomic, retain) NSString * venueName;
@property (nonatomic, retain) NSString * ticketPurchaseUrl;
@property (nonatomic, retain) Event *event;

@end
