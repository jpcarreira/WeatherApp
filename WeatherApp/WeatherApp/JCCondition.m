//
//  JCCondition.m
//  WeatherApp
//
//  Created by João Carreira on 21/03/14.
//  Copyright (c) 2014 João Carreira. All rights reserved.
//

#import "JCCondition.h"

@implementation JCCondition

+(NSDictionary *)imageMap
{
    // static because every instance of JCCondition will use the same instance
    static NSDictionary *imageMap = nil;
    
    // map de condition codes to an image file
    if(!imageMap)
    {
        imageMap = @{
                     @"01d" : @"weather-clear",
                     @"02d" : @"weather-few",
                     @"03d" : @"weather-few",
                     @"04d" : @"weather-broken",
                     @"09d" : @"weather-shower",
                     @"10d" : @"weather-rain",
                     @"11d" : @"weather-tstorm",
                     @"13d" : @"weather-snow",
                     @"50d" : @"weather-mist",
                     @"01n" : @"weather-moon",
                     @"02n" : @"weather-few-night",
                     @"03n" : @"weather-few-night",
                     @"04n" : @"weather-broken",
                     @"09n" : @"weather-shower",
                     @"10n" : @"weather-rain-night",
                     @"11n" : @"weather-tstorm",
                     @"13n" : @"weather-snow",
                     @"50n" : @"weather-mist",
                     };
    }
    return imageMap;
}


// public message to get an image file name
-(NSString *)imageName
{
    return [JCCondition imageMap][self.icon];
}

// mapping the JSON to class properties
+(NSDictionary *)JSONKeyPathsByPropertyKey
{
    // JSON example
    
/*
     {
        "dt": 1384279857,
        "id": 5391959,
        "main": 
        {
            "humidity": 69,
            "pressure": 1025,
            "temp": 62.29,
            "temp_max": 69.01,
            "temp_min": 57.2
        },
        "name": "San Francisco",
        "weather": 
        [
            {
                "description": "haze",
                "icon": "50d",
                "id": 721,
                "main": "Haze"
            }
        ]
     }
*/
    
    return @{@"date": @"dt",
             @"locationName": @"name",
             @"humidity": @"main.humidity",
             @"temperature": @"main.temp",
             @"tempHigh": @"main.temp_max",
             @"tempLow": @"main.temp_min",
             @"sunrise": @"sys.sunrise",
             @"sunset": @"sys.sunset",
             @"conditionDescription": @"weather.description",
             @"condition": @"weather.main",
             @"icon": @"weather.icon",
             @"windBearing": @"wind.deg",
             @"windSpeed": @"wind.speed"
             };
}


// transformer method to turn the NSInteger unix time date to an NSDate object
+(NSValueTransformer *)dateJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString * str){
        return [NSDate dateWithTimeIntervalSince1970:str.floatValue];
    }reverseBlock:^(NSDate *date){
        return [NSString stringWithFormat:@"%f", [date timeIntervalSince1970]];
    }];
}


// reusing above method to transform sunrise and sunset values
+(NSValueTransformer *)sunriseJSONTransformer
{
    return [self dateJSONTransformer];
}


// reusing above method to transform sunrise and sunset values
+(NSValueTransformer *)sunsetJSONTransformer
{
    return [self dateJSONTransformer];
}


// transforming the condition NSArray to a NSString
+(NSValueTransformer *)conditionDescriptionJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSArray *values){
        return [values firstObject];
    }reverseBlock:^(NSString *str){
        return @[str];
    }];
}


// reusing above method to transform condition
+(NSValueTransformer *)conditionJSONTransformer
{
    return [self conditionDescriptionJSONTransformer];
}


// reusing above method to transform condition
+(NSValueTransformer *)iconJSONTransformer
{
    return [self conditionDescriptionJSONTransformer];
}


#define MPS_TO_KMH 3.6f

// transforms miles per second to km per hour
+(NSValueTransformer *)windSpeedJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSNumber *num){
        return @(num.floatValue * MPS_TO_KMH);
    }reverseBlock:^(NSNumber *speed){
        return @(speed.floatValue / MPS_TO_KMH);
    }];
}


// transforms fahrenheit degrees to celsius
+(NSValueTransformer *)temperatureJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSNumber *num){
        return @((num.floatValue - 32.0) / 1.8f);
    }reverseBlock:^(NSNumber *temp){
        return @((temp.floatValue * 1.8) + 32.0);
    }];
}


+(NSValueTransformer *)tempHighJSONTransformer
{
    return [self temperatureJSONTransformer];
}


+(NSValueTransformer *)tempLowJSONTransformer
{
    return [self temperatureJSONTransformer];
}

@end
