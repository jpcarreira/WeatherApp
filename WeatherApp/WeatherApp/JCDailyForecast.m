//
//  JCDailyForecast.m
//  WeatherApp
//
//  Created by João Carreira on 21/03/14.
//  Copyright (c) 2014 João Carreira. All rights reserved.
//

#import "JCDailyForecast.h"

@implementation JCDailyForecast


// overriding JSONKeyPathsByPropertyKey because the current conditions is stored in the key temp_max
// while in the daily forecast is stored as max
+(NSDictionary *)JSONKeyPathsByPropertyKey
{
    /*
     // current conditions
     "main": 
     {
        "grnd_level": 1021.87,
        "humidity": 64,
        "pressure": 1021.87,
        "sea_level": 1030.6,
        "temp": 58.09,
        "temp_max": 58.09,
        "temp_min": 58.09
     }
     
     // daily forecast
     "temp": 
     {
        "day": 58.14,
        "eve": 58.14,
        "max": 58.14,
        "min": 57.18,
        "morn": 58.14,
        "night": 57.18
     }
     */
    
    // getting the JCCondintion's map and creating a copy from it
    NSMutableDictionary *paths = [[super JSONKeyPathsByPropertyKey] mutableCopy];
    
    // changing the desired keys that are different in the daily forecast
    paths[@"tempHigh"] = @"temp.max";
    paths[@"tempLow"] = @"temp.min";
    
    return paths;
}


@end
