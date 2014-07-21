//
//  Formatter.m
//  CollectNumber
//
//  Created by Chie AHAREN on 2014/07/20.
//  Copyright (c) 2014年 Chie AHAREN. All rights reserved.
//

#import "Formatter.h"

@implementation Formatter

+ (NSDateFormatter *)GPSDateFormatter
{
    static NSDateFormatter *dateFormatter;
    
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy:MM:dd";
        dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    }
    
    return dateFormatter;
}

+ (NSDateFormatter *)GPSTimeFormatter
{
    static NSDateFormatter *dateFormatter;
    
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"HH:mm:ss.SSSSSS";
        dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    }
    
    return dateFormatter;
}

@end
