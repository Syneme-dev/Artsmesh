//
//  AMETCDApiTests.m
//  AMETCDApiTests
//
//  Created by 王 为 on 3/5/14.
//  Copyright (c) 2014 王 为. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AMETCD.h"
#import "AMETCDResult.h"

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
   
    AMETCD* service  = [[AMETCD alloc] init];
    service.nodeIp = @"127.0.0.1";
    service.clientPort = 4001;
    service.serverPort = 7001;
    
    [service stopETCD];
    [service startETCD ];
    
    NSString* keyString = @"/message";
    NSString* valueString = @"hello world!";
    
    
    //Test1 setKey
    AMETCDResult* res = [service setKey: keyString withValue:valueString];
    if(res.errCode != 0)
    {
        XCTFail(@"set key failed! error info: %@ \"%s\"\n",
                res.errMessage,
                __PRETTY_FUNCTION__);
        
        [service stopETCD];
        return;
    }
    
    //Test2 getKey and setKey
    res = [service  getKey:keyString];
    if(res.errCode != 0)
    {
        XCTFail(@"get key failed! error info: %@ \"%s\"\n",
                res.errMessage,
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
    
    
    //Test3 watchKey
    int nowIndex = res.node.createdIndex;
    int actualIndex = 0;
    res = [service watchKey:keyString fromIndex:nowIndex acturalIndex:&actualIndex timeout:0];
    if(res.errCode != 0)
    {
        XCTFail(@"wait key failed! error info: %@ \"%s\"\n",
                res.errMessage,
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
    
    //Test4 deleteKey
    res = [service deleteKey:keyString];
    if(res.errCode != 0)
    {
        XCTFail(@"delete key failed! error info: %@ \"%s\"\n",
                res.errMessage,
                __PRETTY_FUNCTION__);
        
        [service stopETCD];
        return;
    }
    
    res = [service getKey:keyString];
    if(res.errCode == 0)
    {
        XCTFail(@"delete key failed! key still exist:%@ \"%s\"\n",
                res.node.value,
                __PRETTY_FUNCTION__);
        
        [service stopETCD];
        return;
    }
    
    
    //Test5 CreateDir
    NSString* dirPath = @"/dir_1";
    res = [service createDir:dirPath];
    if(res.errCode != 0)
    {
        XCTFail(@"create dir failed! :\"%s\"\n",
                __PRETTY_FUNCTION__);
        
        [service stopETCD];
        return;
    }
    
    res = [service getKey:dirPath];
    if(res.errCode != 0)
    {
        XCTFail(@"create dir failed! didn't get the dir %@ :\"%s\"\n",
                dirPath,
                __PRETTY_FUNCTION__);
        
        [service stopETCD];
        return;
    }
    
    //Test6 delete dir
    res = [service deleteDir:dirPath recursive:YES];
    if(res.errCode != 0)
    {
        XCTFail(@"create dir failed! didn't get the dir %@ :\"%s\"\n",
                dirPath,
                __PRETTY_FUNCTION__);
        
        [service stopETCD];
        return;
    }
    
    res = [service getKey:dirPath];
    if(res.errCode == 0)
    {
        XCTFail(@"delete dir failed! the dir still exist :\"%s\"\n",
                __PRETTY_FUNCTION__);
        
        [service stopETCD];
        return;
    }
    
    //Test7 listDir
    NSString* dir1 = @"/dir1/";
    NSString* dir1_dir1 = @"/dir1/dir1/";
    NSString* dir1_key1 = @"/dir1_key1";
    NSString* dir1_value1 = @"/dir1__value1";
    NSString* dir1_dir1_key1 = @"/dir1/dir1/key1";
    NSString* dir1_dir1_value1 = @"/dir1/dir1/value1";
    NSString* dir1_dir1_key2 = @"/dir1/dir1/key2";
    NSString* dir1_dir1_value2 = @"/dir1/dir1/value2";
    
    res = [service deleteDir:dir1 recursive:YES];
    
    res = [service createDir:dir1];
    if(res.errCode != 0)
    {
        XCTFail(@"list dir failed! create failed! :\"%s\"\n",
                __PRETTY_FUNCTION__);
        
        [service stopETCD];
        return;
    }
    
    res = [service createDir:dir1_dir1];
    if(res.errCode != 0)
    {
        XCTFail(@"list dir failed! create failed! :\"%s\"\n",
                __PRETTY_FUNCTION__);
        
        [service stopETCD];
        return;
    }
    
    res = [service setKey:dir1_key1 withValue:dir1_value1];
    if(res.errCode != 0)
    {
        XCTFail(@"list dir failed! create failed! :\"%s\"\n",
                __PRETTY_FUNCTION__);
        
        [service stopETCD];
        return;
    }
    
    res = [service setKey:dir1_dir1_key1 withValue:dir1_dir1_value1];
    if(res.errCode != 0)
    {
        XCTFail(@"list dir failed! create failed! :\"%s\"\n",
                __PRETTY_FUNCTION__);
        
        [service stopETCD];
        return;
    }
    
    res = [service setKey:dir1_dir1_key2 withValue:dir1_dir1_value2];
    if(res.errCode != 0)
    {
        XCTFail(@"list dir failed! create failed! :\"%s\"\n",
                __PRETTY_FUNCTION__);
        
        [service stopETCD];
        return;
    }
    
    res = [service listDir:dir1 recursive:YES];
    if(res.errCode != 0)
    {
        XCTFail(@"list dir failed! create failed! :\"%s\"\n",
                __PRETTY_FUNCTION__);
        
        [service stopETCD];
        return;
    }
    
    int watchDirIndex = res.node.modifiedIndex;
    int watchDirActIndex = 0;
    res = [service watchDir:dir1 fromIndex:watchDirIndex acturalIndex:&watchDirActIndex timeout:0];
    if(res.errCode != 0)
    {
        XCTFail(@"list dir failed! :\"%s\"\n",
                __PRETTY_FUNCTION__);
        
        [service stopETCD];
        return;
    }
    
    if(watchDirIndex != watchDirActIndex)
    {
        XCTFail(@"watch index is not equal to actually index:\"%s\"\n",
                __PRETTY_FUNCTION__);
        
        [service stopETCD];
        return;
    }
    
    //Test8 leader
    NSString* leader = [service getLeader];
    if(leader == nil)
    {
        XCTFail(@"get leader failed:\"%s\"\n",
                __PRETTY_FUNCTION__);
        
        [service stopETCD];
        return;

    }
    
    if([leader isEqualToString:@""])
    {
        XCTFail(@"get leader failed:\"%s\"\n",
                __PRETTY_FUNCTION__);
        
        [service stopETCD];
        return;
    }
    
    NSLog(@"leader is:%@", leader);

    
    [service stopETCD];
}

@end
