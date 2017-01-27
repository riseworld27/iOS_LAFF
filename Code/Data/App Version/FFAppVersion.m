//
//  FFAppVersion.m
//  laff
//
//  Created by matata on 15.03.15.
//  Copyright (c) 2015 matata. All rights reserved.
//

#import "FFAppVersion.h"

#import <TargetConditionals.h>

static NSString * const kKeyLastRunBuild = @"last_run_build";
static NSString * const kKeyLastRunVersion = @"last_run_version";

@implementation FFAppVersion

+ (instancetype)instance {
	static FFAppVersion * _instance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_instance = [FFAppVersion new];
		[_instance setup];
	});
	return _instance;
}
- (void)setup {
	NSBundle * bundle = [NSBundle mainBundle];
	_version = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	_buildFull = [bundle objectForInfoDictionaryKey:@"CFBundleVersion"];
	NSArray * buildComponents = [self.buildFull componentsSeparatedByString:@"."];
	_buildNumber = ((NSString *)buildComponents[0]).integerValue;
	
	/*
	 _isBeta = buildComponents.count > 1 && [((NSString *)buildComponents[1]) isEqualToString:@"0"];
	 
	 _isBeta = [[NSBundle mainBundle] pathForResource:@"embedded" ofType:@"mobileprovision"];
	 */
	
	//	NSLog(@"receipt url: %@", [NSBundle mainBundle].appStoreReceiptURL);
	
	_isBeta = [[NSBundle mainBundle].appStoreReceiptURL.lastPathComponent isEqualToString:@"sandboxReceipt"];
	
#if TARGET_IPHONE_SIMULATOR
	_isBeta = YES;
#endif
	
	_versionAndBuild = self.version;
	if (self.isBeta) {
		_versionAndBuild = [self.versionAndBuild stringByAppendingString:[NSString stringWithFormat:@" (%u) b", (uint)self.buildNumber]];
	}
	
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	
	_lastRunBuildNumber = [defaults integerForKey:kKeyLastRunBuild];
	_lastRunVersion = [defaults stringForKey:kKeyLastRunVersion];
	if (![self.lastRunVersion isEqualToString:self.version]) {
		_lastRunBuildNumber = 0;
	}
	
	[defaults setInteger:self.buildNumber forKey:kKeyLastRunBuild];
	[defaults setObject:self.version forKey:kKeyLastRunVersion];
}

@end
