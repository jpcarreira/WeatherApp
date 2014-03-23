//
//  JCClient.h
//  WeatherApp
//
//  Created by João Carreira on 21/03/14.
//  Copyright (c) 2014 João Carreira. All rights reserved.
//

#import <Foundation/Foundation.h>

@import CoreLocation;
#import <ReactiveCocoa/ReactiveCocoa/ReactiveCocoa.h>

@interface JCClient : NSObject

-(RACSignal *)fecthJSONFromURL:(NSURL *)url;
-(RACSignal *)fecthCurrentConditionForLocation:(CLLocationCoordinate2D)coordinate;
-(RACSignal *)fecthHourlyForecastForLocation:(CLLocationCoordinate2D)coordinate;
-(RACSignal *)fecthDailyForecastForLocation:(CLLocationCoordinate2D)coordinate;

@end
