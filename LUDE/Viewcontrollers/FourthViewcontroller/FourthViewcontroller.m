//
//  FourthViewcontroller.m
//  LUDE
//
//  Created by bluemobi on 15/12/1.
//  Copyright © 2015年 胡祥清. All rights reserved.
//

#import "FourthViewcontroller.h"
#import "AddFriendsViewController.h"
#import "FriendsTableViewCell.h"
#import "FriendsDetailsViewController.h"
#import "MJDIYHeader.h"
#import "MJDIYBackFooter.h"

@interface FourthViewcontroller ()<UINavigationControllerDelegate>

//无好友背景
@property (weak, nonatomic) IBOutlet UIImageView *addFriendBackImageView;
//添加好友按钮
@property (weak, nonatomic) IBOutlet UIButton *addfriendBtn;
//光背景
@property (strong, nonatomic) IBOutlet UIButton *btnAddFriend;
@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@property (strong, nonatomic) IBOutlet UILabel *lblTitleName;

@property (strong ,nonatomic)NSString *pageNoStr;
@property (strong ,nonatomic)NSString *pageCountStr;
@property (strong ,nonatomic)NSMutableArray *addfriendMarr;
@end

@implementation FourthViewcontroller

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_lblTitleName setText:NSLocalizedString(@"FAMILY",nil)];
    [_addfriendBtn setTitle:NSLocalizedString(@"Discover Friend", nil) forState:UIControlStateNormal];
    
    
    [self Initialization];
    //上拉刷新下拉加载
    [self MJView];
  
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_friends_TableView.header beginRefreshing];
    self.navigationController.delegate = self;
}
-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}
-(void)MJView
{
    _friends_TableView.header = [MJDIYHeader headerWithRefreshingBlock:^
                              {
                                  [self createheader];
                              }];
    
    
    _friends_TableView.footer = [MJDIYBackFooter footerWithRefreshingBlock:^
                              {
                                  [self createfooter];
                              }];
}
-(void)createheader
{
    _pageNoStr = @"1";
    [self createData];
    // 马上进入刷新状态
     [_friends_TableView.header endRefreshing];
}

-(void)createfooter
{
    if ([_pageNoStr isEqualToString:_pageCountStr])
    {
        AnimationView *view = [[AnimationView alloc]initWithFrame:CGRectMake(FRAME_W(self.view)/2-60, FRAME_H(self.view)-100, 120, 30)];
        [self.view addSubview:view];
    }
    else
    {
        //加1
        _pageNoStr = [NSString stringWithFormat:@"%d",[_pageNoStr intValue]+1];
        //刷新数据
        [self createData];
    }
    [_friends_TableView.footer endRefreshing];
}

-(void)Initialization
{
    _pageNoStr=@"1";
    _addfriendMarr=[[NSMutableArray alloc]init];
}

-(void)createData
{
    NSDictionary *dict  =[NSDictionary dictionaryWithDictionary:[DEFAULTS objectForKey:@"User"]];
    NSString *userId=[NSString stringWithFormat:@"%@",[[dict objectForKey:@"data"] objectForKey:@"userId"]];
    AJServerApis *apis =[[AJServerApis alloc]init];
    [apis GetMyFriendsListAppUserId:userId pageNo:_pageNoStr pageSize:@"20" andCompletion:^(id objectRet, NSError *errorRes)
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
                [_addfriendMarr removeAllObjects];
            }
            
            NSString *status =[NSString stringWithFormat:@"%@",[objectRet objectForKey:@"status"]];
            if ([status isEqualToString:@"1"])
            {
                _backImageView.hidden = NO;
                _addFriendBackImageView.hidden = YES;
                _addfriendBtn.hidden = YES;
                _friends_TableView.hidden = NO;
                
                NSArray *arr =[NSArray arrayWithArray:[objectRet objectForKey:@"data"]];
                for (int i = 0; i < [arr count]; i++)
                {
                    [_addfriendMarr addObject:arr[i]];
                }
                _pageCountStr =[NSString stringWithFormat:@"%@",[[objectRet objectForKey:@"page"]objectForKey:@"pageCount"]];
                
            }
            else
            {
                _backImageView.hidden = YES;
                _addFriendBackImageView.hidden = NO;
                _addfriendBtn.hidden = NO;
                _friends_TableView.hidden = YES;

            }
            
            [_friends_TableView reloadData];

        }
         if ([_pageNoStr isEqualToString:@"1"])
         {
             [_friends_TableView.header endRefreshing];
         }
         
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_addfriendMarr count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FriendsTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"FriendsTableViewCell"];
    if (cell == nil)
    {
        cell =[[FriendsTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FriendsTableViewCell"];
    }
    cell.backgroundColor =[UIColor clearColor];
    cell.backView.layer.masksToBounds =YES;
    cell.backView.layer.cornerRadius =10;
    
    [cell friendMarr:_addfriendMarr index:indexPath.row];
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FriendsDetailsViewController *FriendsDetails =[[FriendsDetailsViewController alloc]initWithStoryboardID:@"FriendsDetailsViewController"];
    FriendsDetails.friendsId =[NSString stringWithFormat:@"%@",[[_addfriendMarr objectAtIndex:indexPath.row]objectForKey:@"friendId"]];
    FriendsDetails.friendsDetailsDict = [NSDictionary dictionaryWithDictionary:[_addfriendMarr objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:FriendsDetails animated:YES];
}
- (void)didReceiveMemoryWarning
{
   [super didReceiveMemoryWarning];
}

#pragma mark - 按钮点击事件
- (IBAction)AddbtnClick:(id)sender
{
    AddFriendsViewController *addfriend =[[AddFriendsViewController alloc]initWithStoryboardID:@"AddFriendsViewController"];
    [self.navigationController pushViewController:addfriend animated:YES];
}

@end
