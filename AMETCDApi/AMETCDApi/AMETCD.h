//
//  AMETCDApi.h
//  HttpAndJson
//
//  Created by 王 为 on 2/27/14.
//  Copyright (c) 2014 王 为. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMETCDResult.h"

@interface AMETCD : NSObject

@property NSString* leaderAddr;
@property NSString* nodeIp;
@property int serverPort;
@property int clientPort;
@property NSString* nodeName;


//the default ip is host ip,
//client port:4001
//server port: 7001
-(id)init;

//now assume that etcd is in folder /usr/bin/etcd
//will be modified when we designed the physic file path
-(BOOL)startETCD;

//will kill and running etcd instance and run ours
-(void)stopETCD;

//get the cluster's leader
-(NSString*)getLeader;

//get a key command
//the result is in AMETCDResult, see the AMETCDResult to
//know the result structure
-(AMETCDResult*)getKey:(NSString*)key;

//set a key
-(AMETCDResult*)setKey:(NSString*)key
             withValue:(NSString*)value;

//wait the key changing until timeout
//the index_in is the global index we want to wait
//the index_out tell us the latest index of related to the
//key so if we can use 2 as the index_in, if the key exist,
//it will return, then we get the actual index and wait the
//actual index+1. then we will never miss any change of the
//key
-(AMETCDResult*)watchKey:(NSString*)key
                   fromIndex:(int)index_in
                acturalIndex:(int*)index_out
                     timeout:(int)seconds;

//delete a key
-(AMETCDResult*)deleteKey: (NSString*) Key;

//create a dir, if the dir is exist, the return
//resule errCode will not be 0
-(AMETCDResult*)createDir:(NSString*)dirPath;

//delete a dir. if the recursive is NO, only
//delete empty dir, if the recursive is YES
//will delete any dir, except the root dir
-(AMETCDResult*)deleteDir:(NSString*)dirPath
                recursive:(BOOL)b;

//list the Dir
//if the recursive is NO, will only get the current
//content, if the recursive is YES, will also get the content
//in subDir
-(AMETCDResult*)listDir:(NSString*)dirPath
              recursive:(BOOL)bRecursive;


//watch a dir
//the index meaning is the same as watch a key
-(AMETCDResult*)watchDir:(NSString*)dirPath
               fromIndex:(int)index_in
            acturalIndex:(int*)index_out
                 timeout:(int)seconds;

@end
