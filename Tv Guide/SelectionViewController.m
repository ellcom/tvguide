//
//  SelectionViewController.m
//  Tv Guide
//
//  Created by Elliot Adderton on 04/01/2013.
//  Copyright (c) 2013 Elliot Adderton. All rights reserved.
//

#import "SelectionViewController.h"

@interface SelectionViewController ()

@property(strong,nonatomic)NSDictionary *selectedChannelNumbersDict;
@property(strong,nonatomic)NSArray *channelsArray;

@end

@implementation SelectionViewController{}

#pragma mark - LifeCycle

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

#pragma mark - Array / Dict init

-(NSArray*)channelsArray
{
    if(_channelsArray == nil){
        NSString *jsonFileLocation = [[NSBundle mainBundle] pathForResource:@"channels" ofType:@"json"];
        NSData *data = [[NSData alloc] initWithContentsOfFile:jsonFileLocation];
        _channelsArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    }
    return _channelsArray;
}

-(NSDictionary*)selecedChannelNumbersDict
{
    if(_selectedChannelNumbersDict == nil){
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
        for(NSDictionary *channel in [self selectedChannelsArray]){
            [tempDict setValue:@"TRUE" forKey:[channel objectForKey:@"channelNumber"]];
        }
    _selectedChannelNumbersDict = [tempDict mutableCopy];
    }

    return _selectedChannelNumbersDict;
}

-(NSArray*)rebuiltSelectedChannelsArray
{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    for(NSDictionary *channel in self.channelsArray){
        if([[self.selectedChannelNumbersDict objectForKey:[channel objectForKey:@"channelNumber"]] boolValue]){
            [tempArray addObject:channel];
        }
        
    }
    
    return [tempArray mutableCopy];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [self.channelsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"selectionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSString *channelNumber = [[self.channelsArray objectAtIndex:indexPath.row] objectForKey:@"channelNumber"];
    [cell.textLabel setText:channelNumber];
    [cell.detailTextLabel setText:[[self.channelsArray objectAtIndex:indexPath.row] objectForKey:@"channelName"]];
    if([[self.selecedChannelNumbersDict objectForKey:channelNumber] boolValue] == TRUE)
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    else
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *channelNumber = [[self.channelsArray objectAtIndex:indexPath.row] objectForKey:@"channelNumber"];
    
    if([[self.selecedChannelNumbersDict objectForKey:channelNumber] boolValue])
        [self.selecedChannelNumbersDict setValue:@"FALSE" forKey:channelNumber];
        
    else
        [self.selecedChannelNumbersDict setValue:@"TRUE" forKey:channelNumber];
        
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSLog(@"%@ changed",channelNumber);
    [self setSelectedChannelsArray:[self rebuiltSelectedChannelsArray]];
    [tableView reloadData];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
     NSLog(@"Prepare for segue: %@", [segue identifier]);
}

@end
