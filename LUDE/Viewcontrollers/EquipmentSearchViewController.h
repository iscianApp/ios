//
//  EquipmentSearchViewController.h
//  LUDE
//
//  Created by bluemobi on 15/10/9.
//  Copyright © 2015年 胡祥清. All rights reserved.
//

//搜索设备
#import <UIKit/UIKit.h>

@interface EquipmentSearchViewController : UIViewController


@property (weak, nonatomic) IBOutlet UITableView *tableView;

/**
 *	@brief	返回
 */
- (IBAction)returnBtnClick:(UIButton *)sender;
/**
 *	@brief	区分血糖/血压
 */
@property (assign, nonatomic) BOOL typeBOOL;

/**
 *	@brief 手动输入点击事件
 */
- (IBAction)mannueInputDataBtnSelected:(UIButton *)sender;
@end
