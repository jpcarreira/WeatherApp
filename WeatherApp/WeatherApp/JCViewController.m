//
//  JCViewController.m
//  WeatherApp
//
//  Created by João Carreira on 19/03/14.
//  Copyright (c) 2014 João Carreira. All rights reserved.
//

#import "JCViewController.h"
#import <LBBlurredImage/UIImageView+LBBlurredImage.h>
#import "JCManager.h"


@interface JCViewController ()

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) CGFloat screenHeight;

@end

@implementation JCViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // SETTING UP THE STACK OF THREE VIEWS
    
    // storing the screen height will be necessary for the pagging effect
    self.screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    // creating a static background and adding it to the view
    UIImage *background = [UIImage imageNamed:@"bg"];
    self.backgroundImageView = [[UIImageView alloc] initWithImage:background];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.backgroundImageView];
    
    // creating a blurred background
    // (alpha is initially set to 0 to make it visible)
    self.blurredImageView = [[UIImageView alloc] init];
    self.blurredImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.blurredImageView.alpha = 0.0f;
    [self.blurredImageView setImageToBlur:background blurRadius:10 completionBlock:nil];
    [self.view addSubview:self.blurredImageView];
    
    // creating a table view to handle data presentation
    self.tableView = [[UITableView alloc] init];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.2];
    self.tableView.pagingEnabled = YES;
    [self.view addSubview:self.tableView];
    
    
    // SETTING UP LAYOUT FRAMES AND MARGINS
    
    // table header with the same size of the screen
    // (taking advantage of the UITableView paging which will page the header and the daily/hourly forecast sections)
    CGRect headerFrame = [UIScreen mainScreen].bounds;
    
    // inset (padding) to assure that all labels are evenly spaced and centered
    CGFloat inset = 20;
    
    // height variables for the different views
    CGFloat temperatureHeight = 110;
    CGFloat hiloHeight = 40;
    CGFloat iconHeight = 30;
    
    // frames for the labels and icon view based on above constants
    CGRect hiloFrame = CGRectMake(inset, headerFrame.size.height - hiloHeight, headerFrame.size.width - (2 * inset), hiloHeight);
    
    CGRect temperatureFrame = CGRectMake(inset, headerFrame.size.height - (temperatureHeight + hiloHeight), headerFrame.size.width - (2 * inset), temperatureHeight);
    
    CGRect iconFrame = CGRectMake(inset, temperatureFrame.origin.y - iconHeight, iconHeight, iconHeight);
    
    CGRect conditionsFrame = iconFrame;
    conditionsFrame.size.width = self.view.bounds.size.width - (((2 * inset) + iconHeight) + 10);
    conditionsFrame.origin.x = iconFrame.origin.x + (iconHeight + 10);
    
    
    // SETTING UP THE CONTROLS IN THE VIEW
    
    // table header
    UIView *header = [[UIView alloc] initWithFrame:headerFrame];
    header.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = header;
    
    // bottom left label
    UILabel *temperatureLabel = [[UILabel alloc] initWithFrame:temperatureFrame];
    temperatureLabel.backgroundColor = [UIColor clearColor];
    temperatureLabel.textColor = [UIColor whiteColor];
    temperatureLabel.text = @"0º C";
    temperatureLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:120];
    [header addSubview:temperatureLabel];
    
    // bottom left label
    UILabel *hiloLabel = [[UILabel alloc] initWithFrame:hiloFrame];
    hiloLabel.backgroundColor = [UIColor clearColor];
    hiloLabel.textColor = [UIColor whiteColor];
    hiloLabel.text = @"0º / 0º";
    hiloLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:28];
    [header addSubview:hiloLabel];
    
    // top label
    UILabel *cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 30)];
    cityLabel.backgroundColor = [UIColor clearColor];
    cityLabel.textColor = [UIColor whiteColor];
    cityLabel.text = @"Loading ...";
    cityLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cityLabel.textAlignment = NSTextAlignmentCenter;
    [header addSubview:cityLabel];
    
    UILabel *conditionsLabel = [[UILabel alloc] initWithFrame:conditionsFrame];
    conditionsLabel.backgroundColor = [UIColor clearColor];
    conditionsLabel.textColor = [UIColor whiteColor];
    conditionsLabel.text = @"conditions label";
    conditionsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    [header addSubview:conditionsLabel];
    
    // image view for weather icon
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:iconFrame];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    iconView.backgroundColor = [UIColor clearColor];
    iconView.image = [UIImage imageNamed:@"weather-moon"];
    [header addSubview:iconView];
    
    // asking the manager to begin finding the current location of the device
    [[JCManager sharedManager] findCurrentLocation];
    
    // observing the currentCondition key on the manager singleton
    [[RACObserve([JCManager sharedManager], currentCondition)
      // delivering the changes on the main thread since we're updating the UI
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(JCCondition *newCondition){
         // updating the labels with weather data
         // note that we're using newCondition for the text and not the singleton
         // (the subscriber parameter is guaranteed to be the new value)
         temperatureLabel.text = [NSString stringWithFormat:@"%.0fº", newCondition.temperature.floatValue];
         conditionsLabel.text = [newCondition.condition capitalizedString];
         cityLabel.text = [newCondition.locationName capitalizedString];
         
         // uses the mapped image file name to create an image and sets it as the icon for the view
         iconView.image = [UIImage imageNamed:[newCondition imageName]];
     }];
    
    // binding high and low temperature values to hiloLabel's text property
    RAC(hiloLabel, text) = [[RACSignal combineLatest:@[
                        // observe the high and low temperature values of the current condition key
                        // these values are combined and use the latest values of both
                        // the signal fires when either key changes
                        RACObserve([JCManager sharedManager], currentCondition.tempHigh),
                        RACObserve([JCManager sharedManager], currentCondition.tempLow)]
                        // reducing the values to a single value
                        // (the parameter order matches the order of the signals
                        reduce:^(NSNumber *hi, NSNumber *low){
                            return [NSString stringWithFormat:@"%.0f / %.0f", hi.floatValue, low.floatValue];
                        }]
                        // delivering to main thread as we're working on the UI
                        deliverOn:RACScheduler.mainThreadScheduler];
}


// laying out all view
-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGRect bounds = self.view.bounds;
    self.backgroundImageView.frame = bounds;
    self.blurredImageView.frame = bounds;
    self.tableView.frame = bounds;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// status bar style
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


#pragma mark - UITableViewDataSource

// one section for hourly forecasts and another for daily
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // TODO: return count of forecast
    return 0;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    // forecast cells must not be selectable
    // semi-transparent black background and white text
    cell.selectionStyle = UITableViewRowAnimationNone;
    cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    
    // TODO: setup cell
    
    return cell;
}


#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Determine cell height based on screen
    return 44;
}

@end
