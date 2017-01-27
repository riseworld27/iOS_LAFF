//
//  Event+Description.m
//  laff
//
//  Created by matata on 16.03.15.
//  Copyright (c) 2015 matata. All rights reserved.
//

#import "Event+Description.h"

@implementation Event (Description)

- (NSString *)description {
	NSString * detailsString;
	NSMutableArray * details = [NSMutableArray array];
	if (self.countries.length)	[details addObject:self.countries];
	if (self.year.intValue)		[details addObject:self.year];
	if (self.runTime)			[details addObject:[NSString stringWithFormat:@"%@ mins", self.runTime]];
	if (details.count) {
		detailsString = [NSString stringWithFormat:@" (%@)", [details componentsJoinedByString:@", "]];
	} else {
		detailsString = @"";
	}
	return [NSString stringWithFormat:@"%@%@", self.sectionName ?: @"", detailsString];
}

@end
