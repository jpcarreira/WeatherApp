//
//  JCManager.h
//  WeatherApp
//
//  Created by João Carreira on 21/03/14.
//  Copyright (c) 2014 João Carreira. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;
#import <ReactiveCocoa/ReactiveCocoa/ReactiveCocoa.h>

#import "JCCondition.h"

@interface JCManager : NSObject<CLLocationManagerDelegate>

// using instancetype ensures that subclasses will return the appropriate type
+(instancetype)sharedManager;

// properties to store the data
// as we're using a singleton pattern these properties should be accessible anywhere
// readonly ensures that only this class can set their values
@property(nonatomic, strong, readonly) CLLocation *currentLocation;
@property(nonatomic, strong, readonly) JCCondition *currentCondition;
@property(nonatomic, strong, readonly) NSArray *hourlyForecast;
@property(nonatomic, strong, readonly) NSArray *dailyForecast;

// this method will start or refresh the entire location and wheather finding process
-(void)findCurrentLocation;

@end
