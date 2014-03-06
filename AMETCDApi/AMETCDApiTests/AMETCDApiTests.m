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
    [service startETCD ];
    
    NSString* keyString = @"/message";
    NSString* valueString = @"hello world!";
    
    AMETCDCURDResult* res = [service setKey: keyString withValue:valueString];
    if(res.errorRes == YES)
    {
        XCTFail(@"set key failed! error info: %@ \"%s\"\n",
                res.errDescription,
                __PRETTY_FUNCTION__);
        
        [service stopETCD];
        return;
    }
    
    res = [service  getKey:keyString];
    if(res.errorRes == YES)
    {
        XCTFail(@"get key failed! error info: %@ \"%s\"\n",
                res.errDescription,
                __PRETTY_FUNCTION__);
        
        [service stopETCD];
        return;
    }
    
    if (![res.node.value isEqualToString: valueString])
    {
        XCTFail(@"get key failed! set=%@ actual=%@ \"%s\"\n",
                valueString ,
                res.node.value,
                __PRETTY_FUNCTION__);
        
        [service stopETCD];
        return;
    }
    
    int nowIndex = res.node.createdIndex;
    int actualIndex = 0;
    res = [service watchKey:keyString fromIndex:nowIndex acturalIndex:&actualIndex timeout:0];
    if(res.errorRes == YES)
    {
        XCTFail(@"wait key failed! error info: %@ \"%s\"\n",
                res.errDescription,
                __PRETTY_FUNCTION__);
        
        [service stopETCD];
        return;
    }
    
    if (![res.node.value isEqualToString: valueString])
    {
        XCTFail(@"wait key failed! set=%@ actual=%@ \"%s\"\n",
                valueString ,
                res.node.value,
                __PRETTY_FUNCTION__);
        
        [service stopETCD];
        return;
    }
    
    res = [service deleteKey:keyString];
    if(res.errorRes == YES)
    {
        XCTFail(@"delete key failed! error info: %@ \"%s\"\n",
                res.errDescription,
                __PRETTY_FUNCTION__);
        
        [service stopETCD];
        return;
    }
    
    res = [service getKey:keyString];
    if(res.errorRes == NO)
    {
        XCTFail(@"delete key failed! key still exist:%@ \"%s\"\n",
                res.node.value,
                __PRETTY_FUNCTION__);
        
        [service stopETCD];
        return;
    }
    
    
    [service stopETCD];
}

@end
