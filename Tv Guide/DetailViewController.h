//
//  DetailViewController.h
//  Tv Guide
//
//  Created by Elliot Adderton on 05/01/2013.
//  Copyright (c) 2013 Elliot Adderton. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UITableViewController

@property(weak,nonatomic)NSDictionary *channelData;
@property(assign,nonatomic)NSInteger programPointer;

@end
