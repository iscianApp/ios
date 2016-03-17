//
//  MyEquipmentViewController.m
//  LUDE
//
//  Created by JHR on 15/10/14.
//  Copyright © 2015年 胡祥清. All rights reserved.
//

#import "MyEquipmentViewController.h"
#import "EquipmentCell.h"
#import "MJDIYHeader.h"

@interface MyEquipmentViewController ()<UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UILabel *lblMyEquipmen;
@property (strong ,nonatomic)NSString *pageNoStr;
@property (strong ,nonatomic)NSMutableArray *myEquipMarr;
@end

@implementation MyEquipmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_lblMyEquipmen setText:NSLocalizedString(@"MY EQUIPMENT", nil)];
    
    [self Initialization];
    WeakObject(self)
    MJDIYHeader *fresh  = [MJDIYHeader headerWithRefreshingBlock:^{
        [__weakObject createData];
            // 结束刷新
        [__weakObject.myEquipmentTable.header endRefreshing];
    }];
    self.myEquipmentTable.header = fresh;
    self.navigationController.delegate =self;

    [self.myEquipmentTable.header beginRefreshing];
}
-(void)Initialization
{
    _pageNoStr = @"1";
    _myEquipMarr =[[NSMutableArray alloc]init];
}
-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}
-(void)createData
{
    WeakObject(self);
    
    NSDictionary *dict = [DEFAULTS objectForKey:@"User"];
    NSString *userIdStr =[NSString stringWithFormat:@"%@",  [[dict objectForKey:@"data"]objectForKey:@"userId"]];
    
    AJServerApis *apis =[[AJServerApis alloc]init];
    [apis GetUserEquipmentForPageAppUserId:userIdStr pageNo:_pageNoStr pageSize:@"20" andCompletion:^(id objectRet, NSError *errorRes)
    {
        if (errorRes)
        {
            switch (errorRes.code) {
                case -1004:
                {
                    UIAlertView *_alertView = [[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"Please check the network", nil)delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
                    [_alertView show];
                }
                    break;
                case -1001:
                {
                    UIAlertView *_alertView = [[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"Please try again later", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
                    [_alertView show];
                }
                    break;
                case -1009:
                {
                    UIAlertView *_alertView = [[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"Have been disconnected from the Internet", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
                    [_alertView show];
                }
                    break;
                default:
                    break;
            }
        }
        else
        {
            if ([_pageNoStr isEqualToString:@"1"])
            {
                [_myEquipMarr removeAllObjects];
            }
            
            NSString *statusStr =[NSString stringWithFormat:@"%@",[objectRet objectForKey:@"status"]];
            if ([statusStr isEqualToString:@"1"])
            {
                NSArray *arr =[NSArray arrayWithArray:[objectRet objectForKey:@"data"]];
                
                for (int i = 0; i< [arr count]; i++)
                {
                    [__weakObject.myEquipMarr addObject:arr[i]];
                }
                [__weakObject.myEquipmentTable reloadData];
            }
            else
            {
//                    UIAlertView *_alertView = [[UIAlertView alloc]initWithTitle:nil message:[objectRet objectForKey:@"msg"] delegate:nil cancelButtonTitle:NSLocalizedString(@"Confirm", nil)  otherButtonTitles: nil];
//                    [_alertView show];
                [SVProgressHUD showInfoWithStatus:[objectRet objectForKey:@"msg"]];
            }
            [__weakObject.myEquipmentTable reloadData];
        }
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
  
}
/**
 *	@brief	返回按钮 点击事件
 */
- (IBAction)backBtnClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [_myEquipMarr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"EquipmentCell";
    
    EquipmentCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[EquipmentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier
                ];
    }
    
    cell.deleteBtn.tag =100+indexPath.row;
    [cell.deleteBtn addTarget:self action:@selector(deleteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell CreateMarr:_myEquipMarr index:indexPath.row];
    
    return cell;
}

-(void)deleteBtnClick:(UIButton *)sender
{
    WeakObject(self);
    NSString *userEquipmentIdStr =[NSString stringWithFormat:@"%@",[[_myEquipMarr objectAtIndex:sender.tag-100]objectForKey:@"userEquipmentId"]];
    AJServerApis *apis =[[AJServerApis alloc]init];
    [apis GetDeleteUserEquipmentAppUserEquipmentId:userEquipmentIdStr andCompletion:^(id objectRet, NSError *errorRes)
    {
        if (errorRes)
        {
            switch (errorRes.code) {
                case -1004:
                {
                    UIAlertView *_alertView = [[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"Please check the network", nil)delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
                    [_alertView show];
                }
                    break;
                case -1001:
                {
                    UIAlertView *_alertView = [[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"Please try again later", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
                    [_alertView show];
                }
                    break;
                case -1009:
                {
                    UIAlertView *_alertView = [[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"Have been disconnected from the Internet", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
                    [_alertView show];
                }
                    break;
                default:
                    break;
            }
        }
        else
        {
            NSString *statusStr =[NSString stringWithFormat:@"%@",[objectRet objectForKey:@"status"]];
            if ([statusStr isEqualToString:@"1"])
            {
                UIAlertView *alertView =[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Alert", nil) message:[objectRet objectForKey:@"msg"] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Confirm", nil), nil];
                [alertView show];
                
                [__weakObject.myEquipMarr removeObjectAtIndex:sender.tag-100];
                [__weakObject.myEquipmentTable reloadData];
            }
            else
            {
                UIAlertView *alertView =[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Alert", nil) message:[objectRet objectForKey:@"msg"] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Confirm", nil), nil];
                [alertView show];
            }
        }
    }];
}

//-(void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//    //注册通知事件
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"JKSideSlipShow" object:nil userInfo:nil];
//}
@end
