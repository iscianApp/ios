//
//  WebViewController.m
//  LUDE
//
//  Created by JHR on 15/11/19.
//  Copyright © 2015年 胡祥清. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()
@property (strong, nonatomic) IBOutlet UILabel *lblTitleName;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_lblTitleName setText:NSLocalizedString(@"Search Doctor", nil)];
    // Do any additional setup after loading the view.
    
    [self startLoadWeb];
}
- (void)startLoadWeb
{
    NSURLRequest *requestH5 = [NSURLRequest requestWithURL:self.Linkurl];
    [self.webView loadRequest:requestH5];
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [Tools show];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [Tools dismiss];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error
{
    [Tools dismiss];
}

#pragma mark - 按钮点击方法
/**
 *	@brief	返回
 */
- (IBAction)ReturnBtnClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
/**
 *	@brief	分享当前的链接
 */
- (void)shareclik
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
