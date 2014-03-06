//
//  AMETCDApiTests.m
//  AMETCDApiTests
//
//  Created by 王 为 on 3/5/14.
//  Copyright (c) 2014 王 为. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AMETCDService.h"
#import "AMETCDCURDResult.h"

@interface AMETCDApiTests : XCTestCase

@end

@implementation AMETCDApiTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
   // XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
   
    
    AMETCDService* service  = [[AMETCDService alloc] init];
    service.nodeIp = @"192.168.1.101";
    service.clientPort = 4001;
    service.serverPort = 7001;
    
    [service stopETCD];
    
    
    [service startETCD  ];
    
    AMETCDCURDResult* res = [service  getKey:@"/message"];
    
    res = [service setKey:@"/message" withValue:@"hello"];
    
    
    [service stopETCD];
}

@end
