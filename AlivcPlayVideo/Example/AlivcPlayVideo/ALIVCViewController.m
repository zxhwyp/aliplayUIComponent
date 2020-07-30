//
//  ALIVCViewController.m
//  AlivcPlayVideo
//
//  Created by wb-ll501135 on 01/20/2020.
//  Copyright (c) 2020 wb-ll501135. All rights reserved.
//

#import "ALIVCViewController.h"
#import "AlivcVideoPlayTimeShiftViewController.h"
#import "SimplePlayerViewController.h"
#import "AlivcVideoPlayConfigViewController.h"

@interface ALIVCViewController ()

@end

@implementation ALIVCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = NO;
}

- (IBAction)config:(id)sender {
    AlivcVideoPlayConfigViewController *vc = [[AlivcVideoPlayConfigViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)list:(id)sender {
    SimplePlayerViewController *vc = [[SimplePlayerViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)shift:(id)sender {
    AlivcVideoPlayTimeShiftViewController *vc = [[AlivcVideoPlayTimeShiftViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
