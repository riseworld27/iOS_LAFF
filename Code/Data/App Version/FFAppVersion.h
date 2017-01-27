//
//  FFAppVersion.h
//  laff
//
//  Created by matata on 15.03.15.
//  Copyright (c) 2015 matata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FFAppVersion : NSObject

+ (instancetype)instance;

@property (nonatomic, strong, readonly) NSString * version;
@property (nonatomic, strong, readonly) NSString * versionAndBuild;
@property (nonatomic, strong, readonly) NSString * buildFull;
@property (nonatomic, assign, readonly) NSUInteger buildNumber;
@property (nonatomic, assign, readonly) NSUInteger lastRunBuildNumber;
@property (nonatomic, assign, readonly) NSString * lastRunVersion;
@property (nonatomic, assign, readonly) BOOL isBeta;

@end
