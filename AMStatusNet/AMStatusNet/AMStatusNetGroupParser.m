//
//  AMStatusNetGroupParser.m
//  AMStatusNet
//
//  Created by Wei Wang on 7/10/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMStatusNetGroupParser.h"

@implementation AMStatusNetGroupParser

+(NSArray*)parseStatusNetGroups:(NSData*)data
{
    NSError *err = nil;
    id objects = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
    if(err != nil || ![objects isKindOfClass:[NSArray class]]){
        return nil;
    }
    
    NSMutableArray* groups = [[NSMutableArray alloc] init];

    NSArray* result = (NSArray*)objects;
    for(id item in result)
    {
        if (![item isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        
        NSDictionary* groupDict = (NSDictionary*)item;
        AMStatusNetGroup* newGroup = [[AMStatusNetGroup alloc] init];
        newGroup.g_id =groupDict[@"id"];
        newGroup.url = groupDict[@"url"];
        newGroup.nickname =groupDict[@"nickname"];
        newGroup.fullname =groupDict[@"fullname"];
        newGroup.admin_count =groupDict[@"admin_count"];
        newGroup.member_count =groupDict[@"member_count"];
        newGroup.original_logo =groupDict[@"original_logo"];
        newGroup.homepage_logo =groupDict[@"homepage_logo"];
        newGroup.stream_logo =groupDict[@"stream_logo"];
        newGroup.mini_logo =groupDict[@"mini_logo"];
        newGroup.homepage =groupDict[@"homepage"];
        newGroup.description =groupDict[@"description"];
        newGroup.location =groupDict[@"location"];
        newGroup.created =groupDict[@"created"];
        newGroup.modified =groupDict[@"modified"];
        
        [groups addObject:newGroup];
    }
    
    return groups;
}


@end

@implementation AMStatusNetGroup

@end
