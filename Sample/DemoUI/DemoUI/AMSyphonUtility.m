//
//  AMSyphonUtility.m
//  Artsmesh
//
//  Created by 翟英威 on 25/11/2016.
//  Copyright © 2016 Artsmesh. All rights reserved.
//

#import "AMSyphonUtility.h"
#import "AMSyphonCommon.h"




@implementation AMSyphonUtility

+(void) getSyphonDeviceList : (NSMutableArray*) serverNames
{
   // NSMutableArray*         serverNames     = [[NSMutableArray alloc] init];
    NSMutableDictionary*    _syServers      = [[NSMutableDictionary alloc] init];
    NSMutableDictionary*    _processCounter = [[NSMutableDictionary alloc] init];
        
    for(NSDictionary* dict in [SyphonServerDirectory sharedDirectory].servers) {
        NSString* appName   = [dict objectForKey:SyphonServerDescriptionAppNameKey];
        NSString* name      = [dict objectForKey:SyphonServerDescriptionNameKey];
        NSString* title     = [NSString stringWithString:appName];
            
        //Add appName to a dict for ref count
        NSNumber* newNumber;
        NSNumber* number = [_processCounter objectForKey:appName];
        if (number != nil) {
            newNumber = [NSNumber numberWithInt: [number intValue] + 1];
        }else{
            newNumber = [NSNumber numberWithInt:1];
        }
            
        [_processCounter setObject:newNumber forKey:appName];
            
        // A server may not have a name (usually if it is the only server in an application)
        if([name length] > 0) {
            title = [name stringByAppendingFormat:@"-%@", title, nil];
        }
            
        if ([_syServers objectForKey:title] != nil) {
            NSArray* paths = [title componentsSeparatedByString:@"-"];
            NSString* lastPath = [paths lastObject];
                
            NSScanner* scan = [NSScanner scannerWithString:lastPath];
            int val;
            BOOL isInt = [scan scanInt:&val] && [scan isAtEnd];
                
            if (isInt) {
                NSString* titleBody = [title substringToIndex:title.length - lastPath.length - 1];
                title = [NSString stringWithFormat:@"%@%@", titleBody, newNumber];
            }else{
                title = [NSString stringWithFormat:@"%@-%@", title, newNumber];
            }
        }
            
        [_syServers setObject:dict forKey:title];
        [serverNames addObject:title];
    }
        
    return;
}

+(NSArray *) getSyphonClientsList
{
    NSMutableArray* syphonClients = [[NSMutableArray alloc] initWithCapacity:10];
    
    
    return syphonClients;
}

@end
