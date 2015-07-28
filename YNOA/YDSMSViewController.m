//
//  YDSMSViewController.m
//  HNOANew
//
//  Created by 224 on 14-7-25.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import "YDSMSViewController.h"

@interface YDSMSViewController ()

@property (strong, nonatomic) MFMessageComposeViewController *picker;

@end

@implementation YDSMSViewController

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
    // Do any additional setup after loading the view.
    

}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MFMessageComposeViewController Delegate Methods

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    // Notifies users about errors associated with the interface
    switch (result) {
        case MessageComposeResultCancelled:
            NSLog(@"Result: Canceled");
            break;
            
        case MessageComposeResultSent:
            NSLog(@"Result: Sent");
            break;
            
        case MessageComposeResultFailed:
            NSLog(@"Result: Failed");
            break;
            
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
