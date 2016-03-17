//
//  GuideViewController.m
//  LUDE
//
//  Created by JHR on 15/10/9.
//  Copyright © 2015年 胡祥清. All rights reserved.
//
#import "GuideViewController.h"
#import "MainViewController.h"
#import "LoginViewController.h"

@interface GuideViewController ()<UIScrollViewDelegate>

@end

@implementation GuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = YES;
    [self initScrollView];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 自定义方法
/**
 *	@brief	初始化引导页
 */
- (void)initScrollView
{
    UIScrollView *mainScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, [UIScreen mainScreen].bounds.size.height)];
    
    mainScrollView.delegate = self;
    mainScrollView.showsVerticalScrollIndicator = NO; //垂直方向的滚动指示
    mainScrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;//滚动指示的风格
    mainScrollView.showsHorizontalScrollIndicator = NO;//水平方向的滚动指示
    mainScrollView.pagingEnabled = YES;
    mainScrollView.contentSize = CGSizeMake(SCREENWIDTH*3.0, 0);
    mainScrollView.backgroundColor = [UIColor lightGrayColor];
    mainScrollView.bounces = NO;
    
    for (int i = 0; i<3; i++) {
        UIImageView *imageview = [[UIImageView alloc]initWithFrame:CGRectMake(i*SCREENWIDTH, -20, SCREENWIDTH, [UIScreen mainScreen].bounds.size.height+20)];
        if (iPhone4 || iPad)
        {
           imageview.image = [UIImage imageNamed:[NSString stringWithFormat:@"loading_%d",i]];
        }
        else
        {
            imageview.image = [UIImage imageNamed:[NSString stringWithFormat:@"loading_%d",i]];
        }
//
        [mainScrollView addSubview:imageview];
        if (i == 2)
        {
            UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(SCREENWIDTH*2, -20, SCREENWIDTH, [UIScreen mainScreen].bounds.size.height)];
            [btn addTarget:self action:@selector(goIn:) forControlEvents:UIControlEventTouchUpInside];

            [mainScrollView addSubview:btn];
        }
        else
        {
            UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(FRAME_W(self.view)*(i+1)-80, 20, 70, 50)];
            [btn addTarget:self action:@selector(goIn:) forControlEvents:UIControlEventTouchUpInside];
            
            [mainScrollView addSubview:btn];

        }
    }
    [self.view addSubview:mainScrollView];
}

/**
 *	@brief	点击进入主页
 */
- (void)goIn:(UIButton *)sender
{
    LoginViewController *loginView = [[LoginViewController alloc] initWithStoryboardID:@"LoginViewController"];
    loginView.initialInfo = YES;
    
    [self.navigationController pushViewController:loginView animated:YES];
}

@end
