//
//  JCManager.m
//  WeatherApp
//
//  Created by João Carreira on 21/03/14.
//  Copyright (c) 2014 João Carreira. All rights reserved.
//

#import "JCManager.h"
#import "JCClient.h"
#import <TSMessages/TSMessage.h>

@interface JCManager()

// setting the public properties as readwrite
@property(nonatomic, strong, readwrite) CLLocation *currentLocation;
@property(nonatomic, strong, readwrite) JCCondition *currentCondition;
@property(nonatomic, strong, readwrite) NSArray *hourlyForecast;
@property(nonatomic, strong, readwrite) NSArray *dailyForecast;

// properties for location finding and data fetching
@property(nonatomic, strong) CLLocationManager *locationManager;
@property(nonatomic, assign) BOOL isFirstUpdate;
@property(nonatomic, strong) JCClient *client;

@end

@implementation JCManager

// singleton
+(instancetype)sharedManager
{
    static id _sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}


-(id)init
{
    if(self = [super init])
    {
        // creating the locationManager and setting it's delegate to self
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        
        // creating the client object for the manager
        _client = [[JCClient alloc] init];
        
        // the manager observes the current location key on itself using a ReactiveCocoa macro which returns a signal (similar to key-value observing)
        [[[[RACObserve(self, currentLocation)
            // currentLocation must not be nil to continue
            ignore:nil]
           // flattenMap will flat all values and return one object will all signals
           // (whereas flat maps each value)
           flattenMap:^(CLLocation *newLocation)
           {
               return [RACSignal merge:@[
                                         [self updateCurrentConditions],
                                         [self updateDailyForecast],
                                         [self updateHourlyForecast]
                                         ]];
           }]
          // delivers the signal to subscribers on the main thread
          deliverOn:RACScheduler.mainThreadScheduler]
         subscribeError:^(NSError *error){
             // this code, being UI, should be outside the model, but for demonstration purposes it will
             // remain in this place
             [TSMessage showNotificationWithTitle:@"Error" subtitle:@"Problem loading latest weather" type:TSMessageNotificationTypeError];
         }];
    }
    return self;
}


// this method will trigger weather fetching
-(void)findCurrentLocation
{
    self.isFirstUpdate = YES;
    [self.locationManager startUpdatingLocation];
}


// 3 fetch methods which will call methods on the client and save values on the manager
// all methods are bundled up and subscribed to by the RACObservable created in the init method
// they return the same signals that the client returns, which can also be subscribed to
// all property assignements are happening in side-effects with doNext

-(RACSignal *)updateCurrentConditions
{
    return [[self.client fecthCurrentConditionForLocation:self.currentLocation.coordinate] doNext:^(JCCondition *condition){
        self.currentCondition = condition;
    }];
}

-(RACSignal *)updateHourlyForecast
{
    return [[self.client fecthHourlyForecastForLocation:self.currentLocation.coordinate] doNext:^(NSArray *conditions){
        self.hourlyForecast = conditions;
    }];
}

-(RACSignal *)updateDailyForecast
{
    return [[self.client fecthDailyForecastForLocation:self.currentLocation.coordinate] doNext:^(NSArray *conditions){
        self.dailyForecast = conditions;
    }];
}

#pragma mark - CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    // ignoring the first location update as it is almost always cached
    if(self.isFirstUpdate)
    {
        self.isFirstUpdate = NO;
        return;
    }
    
    CLLocation *location = [locations lastObject];
    
    // setting the currentLocation key will trigger the RACObservable that was set in the init
    if(location.horizontalAccuracy > 0)
    {
        self.currentLocation = location;
        [self.locationManager stopUpdatingLocation];
    }
}

@end
