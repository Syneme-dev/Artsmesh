//
//  AMJackHelper.m
//  JackClient
//
//  Created by wangwei on 9/11/14.
//  Copyright (c) 2014 王为. All rights reserved.
//

#import "AMJackHelper.h"

@implementation AMJackHelper

+(NSString*)jackStatusToString:(jack_status_t)status
{
    switch (status) {
        case JackFailure: //0x01
            /**
             * Overall operation failed.
             */
            return @"JackFailure";
            
        case JackInvalidOption: //0x02
            /**
             * The operation contained an invalid or unsupported option.
             */
            return @"JackInvalidOption";
            
        case JackNameNotUnique: //0x04
            /**
             * The desired client name was not unique.  With the @ref
             * JackUseExactName option this situation is fatal.  Otherwise,
             * the name was modified by appending a dash and a two-digit
             * number in the range "-01" to "-99".  The
             * jack_get_client_name() function will return the exact string
             * that was used.  If the specified @a client_name plus these
             * extra characters would be too long, the open fails instead.
             */
            return @"JackNameNotUnique";
            
        case JackServerStarted: //0x08
            /**
             * The JACK server was started as a result of this operation.
             * Otherwise, it was running already.  In either case the caller
             * is now connected to jackd, so there is no race condition.
             * When the server shuts down, the client will find out.
             */
            return @"JackServerStarted";
            
        case JackServerFailed: // 0x10,
            /**
             * Unable to connect to the JACK server.
             */
            return @"JackServerFailed";
            
        case JackServerError: //= 0x20,
            /**
             * Communication error with the JACK server.
             */
            return @"JackServerError";
            
        case JackNoSuchClient:// = 0x40,
            /**
             * Requested client does not exist.
             */
            return @"JackNoSuchClient";
            
        case JackLoadFailure:// = 0x80,
            /**
             * Unable to load internal client
             */
            return @"JackLoadFailure";
            
        case  JackInitFailure:// = 0x100,
            /**
             * Unable to initialize client
             */
            return @"JackInitFailure";
            
        case JackShmFailure:// = 0x200,
            /**
             * Unable to access shared memory
             */
            return @"JackShmFailure";
            
        case JackVersionError:// = 0x400,
            /**
             * Client's protocol version does not match
             */
            return @"JackVersionError";
            
        case JackBackendError:// = 0x800,
            /**
             * Backend error
             */
            return @"JackBackendError";
            
        case JackClientZombie:// = 0x1000
            /**
             * Client zombified failure
             */
            return @"JackClientZombie";
            
        default:
            return [NSString stringWithFormat:@"%x", status];
            
            break;
    }
}


+(float) value_to_db:(float)value
{
    if (value <= 0)
    {
        return -INFINITY;
    }
    
    return 20.0 * log10f(value);
}


+(float) db_to_value:(float) db
{
    return powf(10.0, db/20.0);
}

@end
