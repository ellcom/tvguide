//
//  ProgramViewController.m
//  Tv Guide
//
//  Created by Elliot Adderton on 03/01/2013.
//  Copyright (c) 2013 Elliot Adderton. All rights reserved.
//

#import "ProgramViewController.h"

@interface ProgramViewController ()

@property (strong, nonatomic) NSArray* tvChannels;
@property (strong, nonatomic) NSDictionary* channelData;

@property (assign, nonatomic) BOOL jsonDownloadInProgress;

@end

@implementation ProgramViewController{}

#pragma mark - LifeCycle
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Reload"];
    [refreshControl addTarget:self
                       action:@selector(refreshView)
             forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refreshControl;
    
    [self setJsonDownloadInProgress:NO];
    
    [self.refreshControl beginRefreshing];
    [self channelDataNeedsDownload];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Dictionary and NSArray Methods

-(NSArray*)tvChannels
{
    if(_tvChannels == nil) {
        _tvChannels = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedChannels"];
    }
    
    return _tvChannels;
}

-(void)channelDataNeedsDownload{
    
    if ([self jsonDownloadInProgress] == NO) {
        
        [self setJsonDownloadInProgress:YES];
        NSString* region = @"41016";
        NSString* startTime = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
        NSMutableArray *channelNumbers = [[NSMutableArray alloc] init];
        for(NSDictionary *channel in [self tvChannels])
            [channelNumbers addObject:[channel objectForKey:@"channelNumber"]];
        NSString* channels = [channelNumbers componentsJoinedByString:@":"];

        NSString* contentURL = [NSString stringWithFormat:@"http://player.vir.gin.nl/mpag/api/v1/tv/getNowNextForChannels?region=%@&startTime=%@&channels=%@",region,startTime,channels];
        
        NSURL *url = [NSURL URLWithString:contentURL];
        
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            NSError *error;
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            NSData *data = [NSData dataWithContentsOfURL:url options:kNilOptions error:&error];
            
            if(!error && data && [data length] > 0) {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                if(!error){
                    [self setChannelData:dict];
                    [self.tableView reloadData];
                }else{
                    NSLog(@"Error parsing json file");
                }
                
            }else{
                NSLog(@"Error downloading json file");
                if(!error)
                    error = [[NSError alloc]init];
            }
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [self.refreshControl endRefreshing];
            [self setJsonDownloadInProgress:NO];

            if(error){
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"Couldn't download feed"
                                                               delegate:nil
                                                      cancelButtonTitle:@"Close"
                                                      otherButtonTitles: nil];
                [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
            }
         });
            
        
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.channelData count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    NSString *channelNumber = [[self.tvChannels objectAtIndex:section] objectForKey:@"channelNumber"];
    NSString *channelName = [[self.tvChannels objectAtIndex:section] objectForKey:@"channelName"];
    
    return [NSString stringWithFormat:@"%@ (%@)",channelName,channelNumber];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...

    NSString *channelNumber = [[self.tvChannels objectAtIndex:indexPath.section] objectForKey:@"channelNumber"];
    NSDictionary *program = [[[self.channelData objectForKey:channelNumber] objectForKey:@"programmes"] objectAtIndex:indexPath.row];
    
    [cell.textLabel setText: [program objectForKey:@"title"]];
    
    NSDate *startTime = [NSDate dateWithTimeIntervalSince1970:[[program objectForKey:@"start"] doubleValue]];
    NSDate *endTime = [NSDate dateWithTimeIntervalSince1970:[[program objectForKey:@"end"] doubleValue]];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"HH:mm"];
    
    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@ - %@",
                                   [df stringFromDate:startTime],
                                   [df stringFromDate:endTime]]];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - Storyboard segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"Prepare for segue: %@", [segue identifier]);
    
    
    
    if([[segue identifier] isEqualToString:@"selectedChannelsSegue"]){
        SelectionViewController *svc = [segue destinationViewController];
        [svc setSelectedChannelsArray: self.tvChannels];
    }else if ([[segue identifier] isEqualToString:@"moreDetailSegue"]){
        DetailViewController *dvc = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        NSString *channelNumber = [[self.tvChannels objectAtIndex:indexPath.section] objectForKey:@"channelNumber"];
        [dvc setChannelData:[self.channelData objectForKey:channelNumber]];
        [dvc setProgramPointer:indexPath.row];
    }
}

- (IBAction)done:(UIStoryboardSegue *)segue
{
    SelectionViewController *controller = segue.sourceViewController;
    [self setTvChannels: controller.selectedChannelsArray];
    [[NSUserDefaults standardUserDefaults] setObject:self.tvChannels forKey:@"selectedChannels"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    CGPoint newOffset = CGPointMake(0, -60);
    [self.tableView setContentOffset:newOffset animated:YES];
    
    [self.refreshControl beginRefreshing];
    [self performSelector:@selector(refreshView)];
}

@end
