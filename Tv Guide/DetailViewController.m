//
//  DetailViewController.m
//  Tv Guide
//
//  Created by Elliot Adderton on 05/01/2013.
//  Copyright (c) 2013 Elliot Adderton. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@property(strong,nonatomic)NSDictionary* programDetails;

@end

@implementation DetailViewController{}

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:[[[self.channelData objectForKey:@"programmes"] objectAtIndex:self.programPointer] objectForKey:@"title"]];
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

#pragma mark - Program details init

- (NSDictionary*)programDetails
{
    if(_programDetails == nil){
    
        NSString* programID = [[[self.channelData objectForKey:@"programmes"] objectAtIndex:self.programPointer] objectForKey:@"p_crid"];
        NSString* contentURL = [NSString stringWithFormat:@"http://virgintvguide.mcore.com/mpag/api/v1/tv/getProgramDetails?id=%@",programID];
        
        NSURL *url = [NSURL URLWithString:contentURL];
        
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSError *error;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        NSData *data = [NSData dataWithContentsOfURL:url options:kNilOptions error:&error];
        
        if(!error && data && [data length] > 0) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            if(!error){
                _programDetails = dict;
                [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
            }else{
                NSLog(@"Error parsing json file (c_rid)");
            }
            
        }else{
            NSLog(@"Error downloading json file (c_rid)");
            if(!error)
                error = [[NSError alloc]init];
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self.refreshControl endRefreshing];
        
        if(error){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"Couldn't download synopsis"
                                                               delegate:nil
                                                      cancelButtonTitle:@"Close"
                                                      otherButtonTitles: nil];
            [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
        }
    });
    
    
}

    return _programDetails;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if(indexPath.section == 1 && self.programDetails != nil){
    
        CGSize size = [[[self.programDetails objectForKey:@"Recommendation"] objectForKey:@"Synopsis"]
                        sizeWithFont:[UIFont systemFontOfSize:15]
                        constrainedToSize:CGSizeMake(287, CGFLOAT_MAX)];
        return size.height + 38;
    }
    return  50.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"channelNameCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    if(indexPath.section == 0){
        NSString *channelNumber = [[[self.channelData objectForKey:@"programmes"] objectAtIndex:self.programPointer] objectForKey:@"channelID"];
        NSString *channelName = [self.channelData objectForKey:@"name"];
        [cell.textLabel setText:[NSString stringWithFormat:@"%@  (%@)",channelName,channelNumber]];

        
        NSDate *startTime = [NSDate dateWithTimeIntervalSince1970:[[[[self.channelData objectForKey:@"programmes"] objectAtIndex:self.programPointer] objectForKey:@"start"]  doubleValue]];
        NSDate *endTime = [NSDate dateWithTimeIntervalSince1970:[[[[self.channelData objectForKey:@"programmes"] objectAtIndex:self.programPointer] objectForKey:@"end"]  doubleValue]];
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"HH:mm"];
        
        [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@ - %@",
                                       [df stringFromDate:startTime],
                                       [df stringFromDate:endTime]]];
    }else{
        [cell.textLabel setText:[[[self.channelData objectForKey:@"programmes"] objectAtIndex:self.programPointer] objectForKey:@"title"]];
        
        if([self programDetails] == nil){
            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            
            [cell setAccessoryView: spinner];
            [spinner startAnimating];
            
            [cell.detailTextLabel setText:@"Loading..."];
        }else{
            [cell setAccessoryView:nil];
            [cell.detailTextLabel setText:[[self.programDetails objectForKey:@"Recommendation"] objectForKey:@"Synopsis"]];
        }
    }

    
    [cell setSelectionStyle: UITableViewCellSelectionStyleNone];


    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
