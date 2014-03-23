//
//  JCClient.m
//  WeatherApp
//
//  Created by João Carreira on 21/03/14.
//  Copyright (c) 2014 João Carreira. All rights reserved.
//

#import "JCClient.h"
#import "JCCondition.h"
#import "JCDailyForecast.h"

@interface JCClient()

@property(nonatomic, strong) NSURLSession *session;

@end

@implementation JCClient

-(id)init
{
    if(self = [super init])
    {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config];
    }
    return self;
}


// fecthing the current conditions
-(RACSignal *)fecthJSONFromURL:(NSURL *)url
{
    NSLog(@"Fecthing %@", url.absoluteString);
    
    // returning the signal
    // (this will not execute until the signal is subscribed to fetchJSONFromURL:)
    // creates an object for other methods and objects to use (factory patter)
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber){
        
        // creating a NSURLSessionDataTask to fetch data from the URL
        NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
            
            if(!error)
            {
                NSError *jsonError = nil;
                id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                
                // when JSON data exists and there are no errors, send the subscriber the JSON serialized
                // as either an array or dictionary
                if(!jsonError)
                {
                    [subscriber sendNext:json];
                }
                
                // notifiyng the subscriber when there's a JSON error
                else
                {
                    [subscriber sendError:jsonError];
                }
            }
            // notifiyng the subscriber when there's an error
            else
            {
                [subscriber sendError:error];
            }
            
            // whether there was an error or not, the subscriber gets notified that the request is completed
            [subscriber sendCompleted];
            
        }];
        
        // starts network request once some object subscribes to this signal
        [dataTask resume];
        
        // creates and returns a RACDisposable that handles any cleanup when the signal is destroyed
        return [RACDisposable disposableWithBlock:^{
            [dataTask cancel];
        }];
    }] doError:^(NSError *error){
        
        // adding a "side effect" to log any error that occurs
        // these side effects don't subscribe to the signal for method chaining so we'll just log errors
        NSLog(@"%@", error);
    }];
}


// fetching current conditions
-(RACSignal *)fecthCurrentConditionForLocation:(CLLocationCoordinate2D)coordinate
{
    // formating the URL from a CLLocationCoordinate2D using latitude and longitude
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&units=imperial", coordinate.latitude, coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    
    // using the method above to create the signal
    // since the returned value is a sinal, we can tell other ReactiveCocoa methods on it
    // we'll map the returned value (an NSDictionary) into a different value
    return [[self fecthJSONFromURL:url] map:^(NSDictionary *json){
        // using MTLJSONAdapter to convert the JSON into a JCCondition object
        // (using the MTLJSONSerializing protocol we created on JCCondition)
        return [MTLJSONAdapter modelOfClass:[JCCondition class] fromJSONDictionary:json error:nil];
    }];
}


// fetching the hourly forecast
-(RACSignal *)fecthHourlyForecastForLocation:(CLLocationCoordinate2D)coordinate
{
    // as above, constructing the URL
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast?lat=%f&lon=%f&units=imperial&cnt=12", coordinate.latitude, coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    
    // using fetchJSONFromURL and mapping it accordingly
    return [[self fecthJSONFromURL:url] map:^(NSDictionary *json){
        
        // building a RACSequence from the "list" key of the JOSN
        // (RACSequences allow performing ReactiveCocoa operation on lists)
        RACSequence *list = [json[@"list"] rac_sequence];
        
        // mapping the new list of objects
        // (this calls map on each object in the list, returning a list of new objects)
        return [[list map:^(NSDictionary *item){
        
            // using MTLJSONAdapter to convert JSON into a JCCondition object
            return [MTLJSONAdapter modelOfClass:[JCCondition class] fromJSONDictionary:item error:nil];
            
        // using map on RACSequence returns another RACSequence so we'll get the data as a NSArray
        }] array];
    }];
}


// fetching the daily forecast
-(RACSignal *)fecthDailyForecastForLocation:(CLLocationCoordinate2D)coordinate
{
    // URL
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?lat=%f&lon=%f&units=imperial&cnt=7", coordinate.latitude, coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    
    // using the generic fecth method and mapping results to convert into an array of Mantle objects
    return [[self fecthJSONFromURL:url] map:^(NSDictionary *json){
        
        // building a sequence from the list of raw json
        RACSequence *list = [json[@"list"] rac_sequence];
        
        // mapping results from json to mantle objects
        return [[list map:^(NSDictionary *item){
            return [MTLJSONAdapter modelOfClass:[JCDailyForecast class] fromJSONDictionary:item error:nil];
        }] array];
    }];
}

@end
