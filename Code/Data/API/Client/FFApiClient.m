//
//  PDApiClient.m
//  ParseDemo
//
//  Created by matata on 23.04.14.
//  Copyright (c) 2014 matata. All rights reserved.
//

#import "FFApiClient.h"
#import "FFXMLSerializer.h"
#import "FFConstants.h"

@implementation FFApiClient

+ (instancetype)instance {
	static FFApiClient * _instance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_instance = [[FFApiClient alloc] initWithBaseURL:[NSURL URLWithString:FFConstantBaseAPIURLString]];
		_instance.responseSerializer = [FFXMLSerializer serializer];
	});
	return _instance;
}

- (void)loadEventsDataWithSuccess:(FFApiClientSuccessWithEvents)success failure:(FFApiClientFailure)failure {
//	[self GET:@"title.php" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
//	[self GET:@"feed.xml" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
	[self GET:@"events.xml" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
//		NSLog(@"API. Loaded demo data: %@", responseObject);
		if (success) {
			NSDictionary * data = responseObject;
			id rawEvents = data[@"Event"];
//			NSLog(@"data: %@", data);
			if ([rawEvents isKindOfClass:[NSArray class]]) {
				//// Many events
				NSLog(@"many events");
				success(rawEvents);
			} else if ([rawEvents isKindOfClass:[NSDictionary class]]) {
				//// Single event
				NSLog(@"single event");
				success(@[rawEvents]);
			} else {
				//// No events
				NSLog(@"no events");
				success(@[]);
			}
		}
	} failure:^(NSURLSessionDataTask *task, NSError *error) {
		if (failure) {
			failure(task, error);
		}
	}];
}

@end
