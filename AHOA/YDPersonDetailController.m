//
//  YDPersonDetailController.m
//  HNOANew
//
//  Created by 224 on 14-7-19.
//  Copyright (c) 2014年 zoomlgd. All rights reserved.
//

#import "YDPersonDetailController.h"
#import "YDPersonListController.h"
#import <MessageUI/MessageUI.h>
#import "UIImage+ScaleImage.h"

@interface YDPersonDetailController () <MFMessageComposeViewControllerDelegate>

@end

@implementation YDPersonDetailController

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
    
    //隐藏状态栏
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    
    //背景图片
    UIImageView *imageView=[[UIImageView alloc] initWithFrame:self.tableView.frame];
    imageView.image=[UIImage imageNamed:@"bg.png"];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setBackgroundView:imageView];

    
    self.title=@"人员信息";
    
    UIButton *btn=[[UIButton alloc] init];
    [btn setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    btn.contentMode=UIViewContentModeCenter;
    [btn setFrame:CGRectMake(0, 0, 50, 63)];
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:btn];

    
    //添加手势
    UISwipeGestureRecognizer *swipeReconizer=[[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                       action:@selector(handleSwipe)];
    swipeReconizer.numberOfTouchesRequired=1;
    [swipeReconizer setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipeReconizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleSwipe
{
    [UIView animateWithDuration:.5f animations:^{
        self.view.backgroundColor=[UIColor grayColor];
        self.view.layer.cornerRadius=6.0f;
        self.view.alpha=0.5f;
        self.view.frame=CGRectMake(self.view.frame.size.width/2, self.view.frame.origin.y, 320, 480);
    } completion:^(BOOL finished){
        [UIView animateWithDuration:.5f animations:^{
            [self.navigationController popViewControllerAnimated:NO];
        }];
    }];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

#pragma mark - Table View Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 2;
            break;
            
        case 1:
            return 3;
            break;
            
        case 2:
            return 1;
            break;
            
        default:
            return 0;
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"联系人";
            break;
            
        case 1:
            return @"详细信息";
            break;
            
        case 2:
            return @"备注";
            break;
            
        default:
            return @"";
            break;
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 70;
    }
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"personDetailIdentifier"];
    if (cell == nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"personDetailIdentifier"];
    }
    
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:{
                UIImageView *imageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"people_bg.png"]];
                CGRect bounds = CGRectInset(cell.bounds, 10, 0);
                [imageView setFrame:CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, 70)];
                cell.contentView.clipsToBounds=YES;
                [imageView.layer setMasksToBounds:YES];//设置圆角
                [imageView.layer setCornerRadius:5.f];
                [cell.contentView addSubview:imageView];
                cell.imageView.image=[UIImage imageNamed:@"people_icon.png"];
                break;
            }
             
            case 1:
                cell.textLabel.text=self.person.personname;//人员姓名
                cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
                
            default:
                break;
        }
        
    }else if(indexPath.section == 1){
        UIImage *phoneImage = [UIImage imageNamed:@"phone.png"];
        phoneImage = [phoneImage scaleToSize:CGSizeMake(35, 35)];
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text=[[NSString alloc] initWithFormat:@"所属部门 : %@",self.person.departname];
                break;
                
            case 1:{
                cell.textLabel.text=[[NSString alloc] initWithFormat:@"联系电话: %@",self.person.mobilecode];
                if (cell.accessoryView == nil) {
                    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
                    [button setBackgroundImage:phoneImage forState:UIControlStateNormal];
                    [button setBackgroundImage:phoneImage forState:UIControlStateHighlighted];
                    [button sizeToFit];
                    [button setTag:100001];
                    [button addTarget:self action:@selector(callAction:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView=button;
                }
                break;
            case 2:{
                cell.textLabel.text=[[NSString alloc] initWithFormat:@"短号: %@",self.person.phonecode];
                if (cell.accessoryView == nil) {
                    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
                    [button setBackgroundImage:phoneImage forState:UIControlStateNormal];
                    [button setBackgroundImage:phoneImage forState:UIControlStateHighlighted];
                    [button sizeToFit];
                    [button setTag:100002];
                    [button addTarget:self action:@selector(callAction:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView=button;
                }

            }
            }
                
            default:
                break;
        }

    }else{
        cell.textLabel.text=@"发送短信";
        UIImage *messageImage = [UIImage imageNamed:@"people_send_imag.png"];
        messageImage = [messageImage scaleToSize:CGSizeMake(35, 35)];
        if (cell.accessoryView == nil) {
            UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
            [button setBackgroundImage:messageImage forState:UIControlStateNormal];
            [button setBackgroundImage:messageImage forState:UIControlStateHighlighted];
            [button sizeToFit];
            [button addTarget:self action:@selector(msgAction) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView=button;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)callAction:(UIButton *)sender
{
    NSString *number;
    if (sender.tag == 100001) {
        number = [[NSString alloc]initWithFormat:@"tel://%@",self.person.mobilecode];
    }else {
        number = [[NSString alloc]initWithFormat:@"tel://%@",self.person.phonecode];
    }
    NSLog(@"number=%@",number);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:number]];
}

- (void)msgAction
{
    BOOL canSendSMS=[MFMessageComposeViewController canSendText];
    
    if (canSendSMS) {
        MFMessageComposeViewController *picker=[[MFMessageComposeViewController alloc] init];
        picker.messageComposeDelegate=self;
        picker.navigationBar.tintColor=[UIColor blackColor];
        picker.body=@"你好";
        // 默认收件人(可多个)
        picker.recipients=[NSArray arrayWithObject:self.person.mobilecode];
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath

{
    
    if ([cell respondsToSelector:@selector(tintColor)]) {
        
        if (tableView == self.tableView) {
            
            CGFloat cornerRadius = 5.f;
            
            cell.backgroundColor = UIColor.clearColor;
            
            CAShapeLayer *layer = [[CAShapeLayer alloc] init];
            
            CGMutablePathRef pathRef = CGPathCreateMutable();
            
            CGRect bounds = CGRectInset(cell.bounds, 10, 0);
            
            BOOL addLine = NO;
            
            if (indexPath.row == 0 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
                
                CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius);
                
            } else if (indexPath.row == 0) {
                
                CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
                
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
                
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
                
                CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
                
                addLine = YES;
                
            } else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
                
                CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
                
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
                
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
                
                CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
                
            } else {
                
                CGPathAddRect(pathRef, nil, bounds);
                
                addLine = YES;
                
            }
            
            layer.path = pathRef;
            
            CFRelease(pathRef);
            
            layer.fillColor = [UIColor colorWithWhite:1.f alpha:0.8f].CGColor;
            
            
            
            if (addLine == YES) {
                
                CALayer *lineLayer = [[CALayer alloc] init];
                
                CGFloat lineHeight = (1.f / [UIScreen mainScreen].scale);
                
                lineLayer.frame = CGRectMake(CGRectGetMinX(bounds)+10, bounds.size.height-lineHeight, bounds.size.width-10, lineHeight);
                
                lineLayer.backgroundColor = tableView.separatorColor.CGColor;
                
                [layer addSublayer:lineLayer];
                
            }
            
            UIView *testView = [[UIView alloc] initWithFrame:bounds];
            
            [testView.layer insertSublayer:layer atIndex:0];
            
            testView.backgroundColor = UIColor.clearColor;
            
            cell.backgroundView = testView;
            
        }
        
    }
    
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

@end
