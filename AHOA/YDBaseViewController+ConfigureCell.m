//
//  YDBaseViewController+ConfigureCell.m
//  YNOA
//
//  Created by 224 on 15/7/19.
//  Copyright (c) 2015年 zoomlgd. All rights reserved.
//

#import "YDBaseViewController+ConfigureCell.h"
#import "YDSaleStock.h"

@implementation YDBaseViewController (ConfigureCell)

- (void)configureCell:(UITableViewCell *)cell withSale:(id)sale {
    YDSaleAnaylse *anaylse = (YDSaleAnaylse *)sale;
    for(int i=0;i<kCount-1;i++){
        UIButton *btn=[[UIButton alloc]initWithFrame:CGRectMake(i*kWidth+kMargin, 0, kWidth, kHeight)];
        btn.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
        [btn setContentMode:UIViewContentModeCenter];
        if (self.currentIsSale) {
            if ([self.yorm isEqualToString:@"month"]) {
                switch (i) {
                    case 0:
                        [btn setTitle:anaylse.saleqtym1 forState:UIControlStateNormal];
                        break;
                    case 1:
                        [btn setTitle:anaylse.saleqtym2 forState:UIControlStateNormal];
                        break;
                    case 2:
                        [btn setTitle:anaylse.saleqtym4 forState:UIControlStateNormal];
                        break;
                    case 3:
                        [btn setTitle:anaylse.saleqtym3 forState:UIControlStateNormal];
                        break;
                    case 4:
                        if ([anaylse.price isEqualToString:@"0"]) {
                            [btn setTitle:@"" forState:UIControlStateNormal];
                        }else{
                            [btn setTitle:anaylse.price forState:UIControlStateNormal];
                        }
                        
                        break;
                    default:
                        break;
                }
                
            }
            if ([self.self.yorm isEqualToString:@"year"]) {
                switch (i) {
                    case 0:
                        [btn setTitle:anaylse.saleqtyy1 forState:UIControlStateNormal];
                        break;
                    case 1:
                        [btn setTitle:anaylse.saleqtyy2 forState:UIControlStateNormal];
                        break;
                    case 2:
                        [btn setTitle:anaylse.saleqtyy4 forState:UIControlStateNormal];
                        break;
                    case 3:
                        [btn setTitle:anaylse.saleqtyy3 forState:UIControlStateNormal];
                        break;
                    case 4:
                        if ([anaylse.price isEqualToString:@"0"]) {
                            [btn setTitle:@"" forState:UIControlStateNormal];
                        }else{
                            [btn setTitle:anaylse.price forState:UIControlStateNormal];
                        }
                        
                        break;
                    default:
                        break;
                }
                
            }
        } else {
            if ([self.yorm isEqualToString:@"month"]) {
                switch (i) {
                    case 0:
                        [btn setTitle:anaylse.mo1 forState:UIControlStateNormal];
                        break;
                    case 1:
                        [btn setTitle:anaylse.mo2 forState:UIControlStateNormal];
                        break;
                    case 2:
                        [btn setTitle:anaylse.mo4 forState:UIControlStateNormal];
                        break;
                    case 3:
                        [btn setTitle:anaylse.mo3 forState:UIControlStateNormal];
                        break;
                    default:
                        break;
                }
            }
            if ([self.self.yorm isEqualToString:@"year"]) {
                switch (i) {
                    case 0:
                        [btn setTitle:anaylse.yo1 forState:UIControlStateNormal];
                        break;
                    case 1:
                        [btn setTitle:anaylse.yo2 forState:UIControlStateNormal];
                        break;
                    case 2:
                        [btn setTitle:anaylse.yo4 forState:UIControlStateNormal];
                        break;
                    case 3:
                        [btn setTitle:anaylse.yo3 forState:UIControlStateNormal];
                        break;
                    default:
                        break;
                }
                
            }

        }
        
        
        if ([btn.titleLabel.text hasPrefix:@"-"]) {
            [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }else{
            [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
        [btn setUserInteractionEnabled:NO];
        [cell.contentView addSubview:btn];
    }

}

- (void)configureCell:(UITableViewCell *)cell withStock:(id)stock {
    YDSaleStock *saleStock = (YDSaleStock *)stock;
    for(int i=0;i<kCount-1;i++){
        UIButton *btn=[[UIButton alloc]initWithFrame:CGRectMake(i*kWidth+kMargin, 0, kWidth, kHeight)];
        btn.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
        [btn setContentMode:UIViewContentModeCenter];
        switch (i) {
            case 0:
                [btn setTitle:saleStock.stoday forState:UIControlStateNormal];
                break;
            case 1:
                [btn setTitle:saleStock.swholeYear forState:UIControlStateNormal];
                break;
            case 2:{
                [btn setTitle:saleStock.stockr1 forState:UIControlStateNormal];
            }
                break;
            case 3:
                [btn setTitle:saleStock.stockr2 forState:UIControlStateNormal];
                break;
            default:
                break;
        }
        
        if ([btn.titleLabel.text hasPrefix:@"-"]) {
            [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }else{
            [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
        [btn setUserInteractionEnabled:NO];
        [cell.contentView addSubview:btn];
    }

}

- (void)customTitleView:(NSString *)titleString withDateString:(NSString *)dateString {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(-16, 0, 20, 20)];
    titleLabel.text = titleString;
    titleLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
    [titleLabel sizeToFit];
    [view addSubview:titleLabel];
    if (dateString != nil) {
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(-30, 20, 20, 20)];
        dateLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
        dateLabel.text = [NSString stringWithFormat:@"截止日期:%@",dateString];
        [dateLabel sizeToFit];
        [view addSubview:dateLabel];
    }
    
    self.navigationItem.titleView = view;
}

- (void)customTitleView:(NSString *)titleString withDateString2:(NSString *)dateString {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(-50, 0, 20, 20)];
    titleLabel.text = titleString;
    titleLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
    [titleLabel sizeToFit];
    [view addSubview:titleLabel];
    if (dateString != nil) {
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(-60, 20, 20, 20)];
        dateLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
        dateLabel.text = [NSString stringWithFormat:@"截止日期:%@",dateString];
        [dateLabel sizeToFit];
        [view addSubview:dateLabel];
    }
    
    self.navigationItem.titleView = view;
}

@end
