//
//  ReminderTimeViewController.m
//  LUDE
//
//  Created by bluemobi on 15/10/10.
//  Copyright © 2015年 胡祥清. All rights reserved.
//

#import "ReminderTimeViewController.h"
#import "ReminderTableViewCell.h"
#import "NewRemindViewController.h"
@interface ReminderTimeViewController ()

@property(strong ,nonatomic)NSMutableArray *timeMarr;
@property (strong, nonatomic) IBOutlet UIButton *btnAddReminder;
@property(strong ,nonatomic)NSString *PageNoStr;
@property (strong, nonatomic) IBOutlet UILabel *lblSetReminder;

@end

@implementation ReminderTimeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_lblSetReminder setText:NSLocalizedString(@"Setting Alert", nil)];
    [_btnAddReminder setTitle:NSLocalizedString(@"NEW ALERT", nil) forState:UIControlStateNormal];

    [self Initialization];
 
}
-(void)Initialization
{
    _PageNoStr =@"1";
    _timeMarr =[[NSMutableArray alloc]init];
}
-(void)createData:(BOOL)delete
{
    
    NSDictionary *dict = [DEFAULTS objectForKey:@"User"];
    NSString *userIdStr =[NSString stringWithFormat:@"%@",[[dict objectForKey:@"data"]objectForKey:@"userId"]];
    
    AJServerApis *apis =[[AJServerApis alloc]init];
    [apis GetRemindInfoPageNo:_PageNoStr pageSize:@"20" userId:userIdStr remindType:_remindTypeStr Completion:^(id objectRet, NSError *errorRes)
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
            if ([_PageNoStr isEqualToString:@"1"])
            {
                [_timeMarr removeAllObjects];
            }
            NSString *statusStr =[NSString stringWithFormat:@"%@",[objectRet objectForKey:@"status"]];
            if ([statusStr isEqualToString:@"1"])
            {
                NSArray *arr=[NSArray arrayWithArray:[objectRet objectForKey:@"data"]];
                
                for (int i = 0; i < [arr count]; i++)
                {
                    [_timeMarr addObject:arr[i]];
                }
            }
            else
            {
                UIAlertView *alertView =[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Alert", nil) message:[objectRet objectForKey:@"msg"]delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Confirm", nil), nil];
                [alertView show];
                if (delete == YES)
                {
                    UIAlertView *alertView =[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Alert", nil) message:NSLocalizedString(@"Delete alerts set successfully", nil)delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Confirm", nil), nil];
                    [alertView show];
                }
            }
            
            [_reminderTableView reloadData];
        }
    }];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
 
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //数据请求
    [self createData:NO];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_timeMarr count];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ReminderTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"ReminderTableViewCell"];
    if (cell == nil)
    {
        cell =[[ReminderTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ReminderTableViewCell"];
    }
    
   
  
    cell.timeLabel.text =[NSString stringWithFormat:@"%@:%@", [[_timeMarr objectAtIndex:indexPath.section]objectForKey:@"remindHour"], [[_timeMarr objectAtIndex:indexPath.section]objectForKey:@"remindMinute"]];
    
    cell.backgroundColor =[UIColor clearColor];

    //判断是否为灰色不提醒
    NSString *stateStr =[NSString stringWithFormat:@"%@",[[_timeMarr objectAtIndex:indexPath.section]objectForKey:@"state"]];
    
    if ([stateStr isEqualToString:@"2"])
    {
        cell.reminderSwitch.on = NO;
        cell.timeLabel.textColor = [UIColor darkGrayColor];
        cell.lineImageView.image =[UIImage imageNamed:@"huiduanxian"];
    }
    else
    {
       
        cell.reminderSwitch.on = YES;
        cell.timeLabel.textColor = [UIColor colorWithRed:0 green:0.6581647 blue:0.940235294 alpha:1];
         cell.lineImageView.image =[UIImage imageNamed:@"lvduanxian"];
    }
    
    cell.reminderSwitch.tag = 100 + indexPath.section;
    [cell.reminderSwitch addTarget:self action:@selector(switchBtnClick:) forControlEvents:UIControlEventTouchUpInside];

    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.000001;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *Id =[NSString stringWithFormat:@"%@",[[_timeMarr objectAtIndex:indexPath.section]objectForKey:@"id"]];
    AJServerApis *spis =[[AJServerApis alloc]init];
    [spis GetgetRemindInfoById:Id Completion:^(id objectRet, NSError *errorRes)
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
            }        }
        else
        {
            NSString *statusStr =[NSString stringWithFormat:@"%@", [objectRet objectForKey:@"status"]];
            if ([statusStr isEqualToString:@"1"])
            {
                   NewRemindViewController *New=[[NewRemindViewController alloc]initWithStoryboardID:@"NewRemindViewController"];
                    //编辑时间
                    New.EditOrNOBOOL = YES;
                    New.dict =[NSMutableDictionary dictionaryWithDictionary:[objectRet objectForKey:@"data"]];
                   [self.navigationController pushViewController:New animated:YES];
            }
            else
            {
                UIAlertView *alertView =[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Alert", nil) message:[objectRet objectForKey:@"msg"] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Confirm", nil), nil];
                [alertView show];
            }
        }
    }];
        
  
    
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle==UITableViewCellEditingStyleDelete)
    {
        AJServerApis *apis =[[AJServerApis alloc]init];
        NSString *Id =[NSString stringWithFormat:@"%@",[[_timeMarr objectAtIndex:indexPath.section]objectForKey:@"id"]];
        [apis GetdeleteRemindInfoById:Id Completion:^(id objectRet, NSError *errorRes)
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
                         
                     default:
                         break;
                 }
             }
             else
             {
                 NSString *statusStr =[NSString stringWithFormat:@"%@",[objectRet objectForKey:@"status"]];
                 if ([statusStr isEqualToString:@"1"])
                 {
                     
                     if ( [_timeMarr count] >1)
                     {
                         UIAlertView *alertView =[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Alert", nil) message:[objectRet objectForKey:@"msg"]delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Confirm", nil), nil];
                         [alertView show];
                     }
                   
                     //数据请求
                     [self createData:YES];
                 
                  
                 }
                 else
                 {
                     UIAlertView *alertView =[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Alert", nil) message:[objectRet objectForKey:@"msg"]delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Confirm", nil), nil];
                     [alertView show];
                 }
             }
            
        }];

    }
    
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return NSLocalizedString(@"Delete", nil);
    
}

-(void)switchBtnClick:(UISwitch *)sw
{
    NSString *stateStr;
    if (sw.on == YES)
    {
        
        stateStr =@"1";

    }
    else
    {
        stateStr =@"2";


    }
    
    LLNetApiBase *apis =[[LLNetApiBase alloc]init];
    NSString *IdStr =[NSString stringWithFormat:@"%@",[[_timeMarr objectAtIndex:sw.tag-100]objectForKey:@"id"]];
    
    [apis PostupdateRemindInfoStateId:IdStr state:stateStr andCompletion:^(id objectRet, NSError *errorRes)
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
                UIAlertView *alertView =[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Alert", nil) message:[objectRet objectForKey:@"msg"]delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Confirm", nil), nil];
                [alertView show];
              
            }
            else
            {
                UIAlertView *alertView =[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Alert", nil) message:[objectRet objectForKey:@"msg"]delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Confirm", nil), nil];
                [alertView show];
            }
            [self createData:NO];
        }
    }];
    

}

#pragma mark - 按钮点击事件
/**
 *	@brief	返回
 */
- (IBAction)ReturnBtnClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
/**
 *	@brief	新增
 */
- (IBAction)AddbtnClick:(UIButton *)sender
{
    if ([_timeMarr count]>9)
    {
        UIAlertView *alertView =[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Alert", nil) message:NSLocalizedString(@"Reminder time can not be more than 10", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Confirm", nil), nil];
        [alertView show];
    }
    else
    {
        NewRemindViewController *New=[[NewRemindViewController alloc]initWithStoryboardID:@"NewRemindViewController"];
        New.remindTypeStr =_remindTypeStr;
        [self.navigationController pushViewController:New animated:YES];
        
    
    }
    
    
}
@end
