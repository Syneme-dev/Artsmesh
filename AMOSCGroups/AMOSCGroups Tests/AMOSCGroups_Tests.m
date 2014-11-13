//
//  AMOSCGroups_Tests.m
//  AMOSCGroups Tests
//
//  Created by 王为 on 13/11/14.
//  Copyright (c) 2014 王为. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "AMOSCGroups.h"

@interface AMOSCGroups_Tests : XCTestCase

@property AMOSCGroups* client;

@end

@implementation AMOSCGroups_Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    self.client = [[AMOSCGroups alloc] init];
    
    [self.client startOSCGroupClient];
    
    
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
}

@end
