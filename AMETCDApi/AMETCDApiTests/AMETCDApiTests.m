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
#import "AMNetworkUtils/AMNetworkUtils.h"

@interface AMETCDApiTests : XCTestCase
{
    NSTask* _etcdTask;
}

@end

@implementation AMETCDApiTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    if(_etcdTask != nil)
    {
        return;
    }
    
    _etcdTask = [[NSTask alloc] init];
    _etcdTask.launchPath = @"/usr/bin/etcd";
    //_etcdTask.arguments = nil;
    
    [_etcdTask launch];
}

- (void)tearDown
{
    [NSTask launchedTaskWithLaunchPath:@"/usr/bin/killall"
                             arguments:[NSArray arrayWithObjects:@"-c", @"etcd", nil]];
    sleep(1);
    _etcdTask = nil;
    
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
   // XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
   
    AMETCD* service  = [[AMETCD alloc] initWithService:@"127.0.0.1" port:4001];
    
    NSString* keyString = @"/message";
    NSString* valueString = @"hello world!";
    
    //Test1 setKey
    AMETCDResult* res = [service setKey:keyString withValue:valueString ttl:0];
    if(res.errCode != 0)
    {
        XCTFail(@"set key failed! error info: %@ \"%s\"\n",
                res.errMessage,
                __PRETTY_FUNCTION__);
        return;
    }
    
    //Test2 getKey and setKey
    res = [service  getKey:keyString];
    if(res.errCode != 0)
    {
        XCTFail(@"get key failed! error info: %@ \"%s\"\n",
                res.errMessage,
                __PRETTY_FUNCTION__);
        return;
    }
    
    if (![res.node.value isEqualToString: valueString])
    {
        XCTFail(@"get key failed! set=%@ actual=%@ \"%s\"\n",
                valueString ,
                res.node.value,
                __PRETTY_FUNCTION__);
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
    
        return;
    }
    
    if (![res.node.value isEqualToString: valueString])
    {
        XCTFail(@"wait key failed! set=%@ actual=%@ \"%s\"\n",
                valueString ,
                res.node.value,
                __PRETTY_FUNCTION__);
    
        return;
    }
    
    //Test4 deleteKey
    res = [service deleteKey:keyString];
    if(res.errCode != 0)
    {
        XCTFail(@"delete key failed! error info: %@ \"%s\"\n",
                res.errMessage,
                __PRETTY_FUNCTION__);
    
        return;
    }
    
    res = [service getKey:keyString];
    if(res.errCode == 0)
    {
        XCTFail(@"delete key failed! key still exist:%@ \"%s\"\n",
                res.node.value,
                __PRETTY_FUNCTION__);
    
        return;
    }
    
    
    //Test5 CreateDir
    NSString* dirPath = @"/dir_1";
    res = [service createDir:dirPath];
    if(res.errCode != 0)
    {
        XCTFail(@"create dir failed! :\"%s\"\n",
                __PRETTY_FUNCTION__);

        return;
    }
    
    res = [service getKey:dirPath];
    if(res.errCode != 0)
    {
        XCTFail(@"create dir failed! didn't get the dir %@ :\"%s\"\n",
                dirPath,
                __PRETTY_FUNCTION__);
        
        return;
    }
    
    //Test6 delete dir
    res = [service deleteDir:dirPath recursive:YES];
    if(res.errCode != 0)
    {
        XCTFail(@"create dir failed! didn't get the dir %@ :\"%s\"\n",
                dirPath,
                __PRETTY_FUNCTION__);
        
        return;
    }
    
    res = [service getKey:dirPath];
    if(res.errCode == 0)
    {
        XCTFail(@"delete dir failed! the dir still exist :\"%s\"\n",
                __PRETTY_FUNCTION__);
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
        return;
    }
    
    res = [service createDir:dir1_dir1];
    if(res.errCode != 0)
    {
        XCTFail(@"list dir failed! create failed! :\"%s\"\n",
                __PRETTY_FUNCTION__);
        
        return;
    }
    
    res = [service setKey:dir1_key1 withValue:dir1_value1 ttl:0];
    if(res.errCode != 0)
    {
        XCTFail(@"list dir failed! create failed! :\"%s\"\n",
                __PRETTY_FUNCTION__);

        return;
    }
    
    res = [service setKey:dir1_dir1_key1 withValue:dir1_dir1_value1 ttl:0];
    if(res.errCode != 0)
    {
        XCTFail(@"list dir failed! create failed! :\"%s\"\n",
                __PRETTY_FUNCTION__);

        return;
    }
    
    res = [service setKey:dir1_dir1_key2 withValue:dir1_dir1_value2 ttl:0];
    if(res.errCode != 0)
    {
        XCTFail(@"list dir failed! create failed! :\"%s\"\n",
                __PRETTY_FUNCTION__);

        return;
    }
    
    res = [service listDir:dir1 recursive:YES];
    if(res.errCode != 0)
    {
        XCTFail(@"list dir failed! create failed! :\"%s\"\n",
                __PRETTY_FUNCTION__);

        return;
    }
    
    int watchDirIndex = res.node.modifiedIndex;
    int watchDirActIndex = 0;
    res = [service watchDir:dir1 fromIndex:watchDirIndex acturalIndex:&watchDirActIndex timeout:0];
    if(res.errCode != 0)
    {
        XCTFail(@"list dir failed! :\"%s\"\n",
                __PRETTY_FUNCTION__);

        return;
    }
    
    if(watchDirIndex != watchDirActIndex)
    {
        XCTFail(@"watch index is not equal to actually index:\"%s\"\n",
                __PRETTY_FUNCTION__);
        
        return;
    }
    
    //Test8 leader
    NSString* leader = [service getLeader];
    if(leader == nil)
    {
        XCTFail(@"get leader failed:\"%s\"\n",
                __PRETTY_FUNCTION__);
        
        return;

    }
    
    if([leader isEqualToString:@""])
    {
        XCTFail(@"get leader failed:\"%s\"\n",
                __PRETTY_FUNCTION__);
        
        return;
    }
    
    NSLog(@"leader is:%@", leader);
    
    //Test8 TTL
    NSString* ttlKey = @"ttlk";
    NSString* ttlVal = @"ttlv";
    
    res = [service setKey:ttlKey withValue:ttlVal ttl:5];
    if(res.errCode != 0)
    {
        XCTFail(@"setKey failed! :\"%s\"\n",
                __PRETTY_FUNCTION__);
        
        return;
    }
    
    res = [service getKey:ttlKey];
    if(res.errCode != 0)
    {
        XCTFail(@"getKey failed! :\"%s\"\n",
                __PRETTY_FUNCTION__);
        
        return;
    }
    
    if (![res.node.value isEqualToString:ttlVal])
    {
        XCTFail(@"getkey is no equan to setkey failed! :\"%s\"\n",
                __PRETTY_FUNCTION__);
        
        return;
    }
    
    sleep(8);
    
    res = [service getKey:ttlKey];
    if(res.errCode == 0)
    {
        XCTFail(@"the key is still live! :\"%s\"\n",
                __PRETTY_FUNCTION__);
        
        return;
    }

    
}

@end
