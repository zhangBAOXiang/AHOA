//
//  YDBaseViewController+ConfigureCell.m
//  YNOA
//
//  Created by 224 on 15/7/19.
//  Copyright (c) 2015年 zoomlgd. All rights reserved.
//

#import "YDBaseViewController+ConfigureCell.h"

@implementation YDBaseViewController (ConfigureCell)

- (void)configureCell:(UITableViewCell *)cell withSale:(YDSaleAnaylse *)sale {
    for(int i=0;i<kCount-1;i++){
        UIButton *btn=[[UIButton alloc]initWithFrame:CGRectMake(i*kWidth+kMargin, 0, kWidth, kHeight)];
        [btn setContentMode:UIViewContentModeCenter];
        if ([self.yorm isEqualToString:@"month"]) {
            switch (i) {
                case 0:
                    [btn setTitle:sale.saleqtym1 forState:UIControlStateNormal];
                    break;
                case 1:
                    [btn setTitle:sale.saleqtym2 forState:UIControlStateNormal];
                    break;
                case 2:
                    [btn setTitle:sale.saleqtym4 forState:UIControlStateNormal];
                    break;
                case 3:
                    [btn setTitle:sale.saleqtym3 forState:UIControlStateNormal];
                    break;
                case 4:
                    if ([sale.price isEqualToString:@"0"]) {
                        [btn setTitle:@"" forState:UIControlStateNormal];
                    }else{
                        [btn setTitle:sale.price forState:UIControlStateNormal];
                    }
                    
                    break;
                default:
                    break;
            }
            
        }
        if ([self.self.yorm isEqualToString:@"year"]) {
            switch (i) {
                case 0:
                    [btn setTitle:sale.saleqtyy1 forState:UIControlStateNormal];
                    break;
                case 1:
                    [btn setTitle:sale.saleqtyy2 forState:UIControlStateNormal];
                    break;
                case 2:
                    [btn setTitle:sale.saleqtyy4 forState:UIControlStateNormal];
                    break;
                case 3:
                    [btn setTitle:sale.saleqtyy3 forState:UIControlStateNormal];
                    break;
                case 4:
                    if ([sale.price isEqualToString:@"0"]) {
                        [btn setTitle:@"" forState:UIControlStateNormal];
                    }else{
                        [btn setTitle:sale.price forState:UIControlStateNormal];
                    }
                    
                    break;
                default:
                    break;
            }
            
        }
        if ([btn.titleLabel.text hasPrefix:@"-"]) {
            [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }else{
            [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
        [btn setUserInteractionEnabled:NO];
        btn.titleLabel.font = [UIFont fontWithName:@"STHeiti-Medium.ttc" size:10];
        [cell.contentView addSubview:btn];
    }

}

- (void)customTitleView:(NSString *)titleString withDateString:(NSString *)dateString {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    titleLabel.text = titleString;
    titleLabel.font = [UIFont systemFontOfSize:16];
    [titleLabel sizeToFit];
    [view addSubview:titleLabel];
    if (dateString != nil) {
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(-30, 20, 20, 20)];
        dateLabel.font = [UIFont systemFontOfSize:12];
        dateLabel.text = [NSString stringWithFormat:@"截止日期:%@",dateString];
        [dateLabel sizeToFit];
        [view addSubview:dateLabel];
    }
    
    self.navigationItem.titleView = view;
}

- (void)customTitleView:(NSString *)titleString withDateString2:(NSString *)dateString {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(-40, 0, 20, 20)];
    titleLabel.text = titleString;
    titleLabel.font = [UIFont systemFontOfSize:16];
    [titleLabel sizeToFit];
    [view addSubview:titleLabel];
    if (dateString != nil) {
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(-60, 20, 20, 20)];
        dateLabel.font = [UIFont systemFontOfSize:12];
        dateLabel.text = [NSString stringWithFormat:@"截止日期:%@",dateString];
        [dateLabel sizeToFit];
        [view addSubview:dateLabel];
    }
    
    self.navigationItem.titleView = view;
}

@end
