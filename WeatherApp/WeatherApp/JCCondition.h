//
//  JCCondition.h
//  WeatherApp
//
//  Created by João Carreira on 21/03/14.
//  Copyright (c) 2014 João Carreira. All rights reserved.
//

#import "MTLModel.h"

// data mapping and value transformation
#import <Mantle.h>

// MTLJSONSerializing protocol to tell the Mantle serializer that this object has instructions
// on how to map JSON to obj-C properties
@interface JCCondition : MTLModel<MTLJSONSerializing>

// some properties won't be need
// (we'll only use two)
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSNumber *humidity;
@property (nonatomic, strong) NSNumber *temperature;
@property (nonatomic, strong) NSNumber *tempHigh;
@property (nonatomic, strong) NSNumber *tempLow;
@property (nonatomic, strong) NSString *locationName;
@property (nonatomic, strong) NSDate *sunrise;
@property (nonatomic, strong) NSDate *sunset;
@property (nonatomic, strong) NSString *conditionDescription;
@property (nonatomic, strong) NSString *condition;
@property (nonatomic, strong) NSNumber *windBearing;
@property (nonatomic, strong) NSNumber *windSpeed;
// this will be used as a key to get an image from a dictionary
@property (nonatomic, strong) NSString *icon;

// helper method to map the weather condition to an image file
-(NSString *)imageName;

@end
