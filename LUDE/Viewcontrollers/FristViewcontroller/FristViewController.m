//
//  FristViewController.m
//  LUDE
//
//  Created by bluemobi on 15/12/1.
//  Copyright © 2015年 胡祥清. All rights reserved.
//

#import "FristViewController.h"
#import "TimeReminderViewController.h"
#import "EquipmentSearchViewController.h"
#import "BPMeasurementGuidanceViewController.h"
#import "baseChartView.h"
#import "BloodDataDeneralizationViewController.h"
#import "PressureDataModel.h"
#import "BloodRressureMonitoringViewController.h"
#import "APService.h"
@interface FristViewController ()<UINavigationControllerDelegate,AutoConnectSucceed>
{
    Tools *BlueTooth;
    
    CGRect SplinesFrame;
    CGRect DBlinesFrame;
}
@property (strong, nonatomic) IBOutlet UILabel *lblDIA;
@property (strong, nonatomic) IBOutlet UILabel *lblSYS;
@property (strong, nonatomic) IBOutlet UILabel *lblPUL;
//红点
@property (weak, nonatomic) IBOutlet UIImageView *hasNewNoti;
//收缩压（折线图）
@property (strong, nonatomic) IBOutlet GCView *ringView;
@property (weak, nonatomic) IBOutlet UIView *OnView;
@property (weak, nonatomic) IBOutlet UIView *borrowView;

//收缩压（折线图）
@property (strong, nonatomic) IBOutlet baseChartView *SPLinesView;
//舒张压（折线图）
@property (strong, nonatomic) IBOutlet baseChartView *DBLinesView;
//收缩压
@property (weak, nonatomic) IBOutlet UILabel *SPLabel;
//舒张压
@property (weak, nonatomic) IBOutlet UILabel *DBLabel;
//心率
@property (weak, nonatomic) IBOutlet UILabel *heartRateLabel;
//日期
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
//收缩压(平均)
@property (weak, nonatomic) IBOutlet UILabel *SPAverageLabel;
//收缩压(最高)
@property (weak, nonatomic) IBOutlet UILabel *SPTopLabel;
//舒张压(平均)
@property (weak, nonatomic) IBOutlet UILabel *DBPAverageLabel;
//舒张压(最高)
@property (weak, nonatomic) IBOutlet UILabel *DBPTopLabel;

@property (nonatomic ,strong)NSMutableArray *messageArray;
@property (strong ,nonatomic)NSMutableDictionary *fristDict;

@property (weak, nonatomic) IBOutlet UILabel *healthIndex;
@property (weak, nonatomic) IBOutlet UILabel *dspLabelAve;
@property (weak, nonatomic) IBOutlet UILabel *spLableAve;
@property (weak, nonatomic) IBOutlet UILabel *dspMaxLable;
@property (weak, nonatomic) IBOutlet UILabel *spMaxLable;

@property (weak, nonatomic) IBOutlet UIButton *measureBtn;

@property (nonatomic ,strong) NSArray *unReadMessageArray;

@property (weak, nonatomic) IBOutlet UIView *downView;
@end

@implementation FristViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
     [_lblDIA setText:NSLocalizedString(@"DIA", nil)];
     [_lblPUL setText:NSLocalizedString(@"PUL", nil)];
     [_lblSYS setText:NSLocalizedString(@"SYS", nil)];
     [_healthIndex setText:NSLocalizedString(@"Health Index", nil)];
     [_dspLabelAve setText:NSLocalizedString(@"SYS(A)", nil)];
     [_spLableAve setText:NSLocalizedString(@"DIA(A)", nil)];
     [_dspMaxLable setText:NSLocalizedString(@"SYS(max)", nil)];
     [_spMaxLable setText:NSLocalizedString(@"DIA(max)", nil)];
    [_measureBtn setTitle:NSLocalizedString(@"Start", nil) forState:UIControlStateNormal];
    _timeLabel.text =[NSString stringWithFormat:@"%@：",NSLocalizedString(@"DATE", nil)];
    
    
    self.hasNewNoti.hidden = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivedApns:) name:@"apns" object:nil];
    //监听通知事件
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(redOriginHidden:)
                                                 name:@"redOriginHidden"
                                               object:nil];
    if ([[NTAccount shareAccount] Messages])
    {
        self.messageArray = [[NSMutableArray alloc] initWithArray:[[NTAccount shareAccount] Messages]];
    }
    else
    {
        self.messageArray = [[NSMutableArray alloc] init];
    }
    
//    [self.messageArray enumerateObjectsUsingBlock:^(LUDEMessage *Mess, NSUInteger idx, BOOL *stop)
//     {
//        if (Mess.PushType.integerValue != 2 )
//        {
//            self.hasNewNoti.hidden = NO;
//        }
//    }];
    [self.messageArray enumerateObjectsUsingBlock:^(NSString *Mess, NSUInteger idx, BOOL *stop) {
        if (Mess.integerValue != 2 )
        {
            self.hasNewNoti.hidden = NO;
        }
    }];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(StarBtnDefaultShow)
                                                 name:@"StarBtnDefaultShow"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(StarBtnDefaultHide)
                                                 name:@"StarBtnDefaultHide"
                                               object:nil];

}
//极光接收到数据时候调用的方法
-(void)DidReceiveMessage:(NSNotification *)info
{
    self.hasNewNoti.hidden = NO;
}
-(void)redOriginHidden:(NSNotification *)info
{
    self.hasNewNoti.hidden = YES;
}
-(void)didReceivedApns:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification object];
    NSString *str = [userInfo valueForKey:@"pushType"]; //推送显示的内容
    if (![str isEqualToString:@"2"])
    {
        self.hasNewNoti.hidden = NO;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.delegate = self;
     [self createData];
}
-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}
-(void)createData
{
    WeakObject(self)
    NSString *userId =[NSString stringWithFormat:@"%@",[[[DEFAULTS objectForKey:@"User"]objectForKey:@"data"]objectForKey:@"userId"]];
    AJServerApis *apis =[[AJServerApis alloc]init];
    [apis GetBloodPressureUserId:userId andCompletion:^(id objectRet, NSError *errorRes)
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
            NSString *statusStr =[NSString stringWithFormat:@"%@",[objectRet objectForKey:@"status"]];
            if ([statusStr isEqualToString:@"1"])
            {
                _fristDict = [NSMutableDictionary dictionaryWithDictionary:[objectRet objectForKey:@"data"]];
                [__weakObject createUI];
            }
            else
            {
                [_SPLinesView drawWithTheDataArray:@[@"",@"",@""]];
                [_DBLinesView drawWithTheDataArray:@[@"",@"",@""]];

            }
        }
        
    }];
    
}

-(void)createUI
{
    if (_fristDict) {
        self.unReadMessageArray = _fristDict[@"pushType"];
        NSMutableArray *tempSaveArray ;
        if (self.unReadMessageArray.count > 0) {
            self.hasNewNoti.hidden = NO;
            [[NSNotificationCenter defaultCenter]   postNotificationName:@"redOriginalAppear" object:nil];
            for (int i = 0; i < self.unReadMessageArray.count; i++) {
                NSString *pushType = [NSString stringWithFormat:@"%@",self.unReadMessageArray[i]];
                if ([[NTAccount shareAccount] Messages]) {
                    tempSaveArray = [[NSMutableArray alloc] initWithArray:[[NTAccount shareAccount] Messages]];
                }
                else
                {
                    tempSaveArray = [[NSMutableArray alloc] init];
                }
//                LUDEMessage *message = [[LUDEMessage alloc] init];
//                message.read = [NSNumber numberWithBool:NO];
//                message.PushType = pushType;
//                [tempSaveArray insertObject:message atIndex:0];
                
                if(![tempSaveArray containsObject:pushType])
                {
                    [tempSaveArray addObject:pushType];
                }
            }
            [[NTAccount shareAccount] setMessages:tempSaveArray];
            
        }
    }
    
    //日期
    _timeLabel.text =[NSString stringWithFormat:@"%@：%@",NSLocalizedString(@"DATE", nil),[_fristDict objectForKey:@"measureTime"]];
  
    SplinesFrame = _SPLinesView.frame;
    DBlinesFrame = _DBLinesView.frame;
    
    [_SPLinesView removeFromSuperview];
    [_DBLinesView removeFromSuperview];
    
    _SPLinesView =[[baseChartView alloc]initWithFrame:SplinesFrame];
    [_OnView addSubview:_SPLinesView];
    _DBLinesView =[[baseChartView alloc]initWithFrame:DBlinesFrame];
    [_borrowView addSubview:_DBLinesView];
    
    [_SPLinesView drawWithTheDataArray:[_fristDict objectForKey:@"bloodPressureCloseList"]];
    [_DBLinesView drawWithTheDataArray:[_fristDict objectForKey:@"bloodPressureOpenList"]];
    _SPLabel.text =[NSString stringWithFormat:@"%@",[_fristDict objectForKey:@"bloodPressureClose"]];
    [_SPLabel setFont:[Tools fontFromFloatValue:50.0]];
    [_SPLabel sizeToFit];
    
    _DBLabel.text =[NSString stringWithFormat:@"%@",[_fristDict objectForKey:@"bloodPressureOpen"]];
    [_DBLabel setFont:[Tools fontFromFloatValue:50.0]];
    [_DBLabel sizeToFit];
    
    _heartRateLabel.text =[NSString stringWithFormat:@"%@",[_fristDict objectForKey:@"pulse"]];
    _SPAverageLabel.text=[NSString stringWithFormat:@"%@",[_fristDict objectForKey:@"bloodPressureCloseAvg"]];
    [_SPAverageLabel setFont:[Tools fontFromFloatValue:20.0]];
    [_SPAverageLabel sizeToFit];
    
    _SPTopLabel.text=[NSString stringWithFormat:@"%@",[_fristDict objectForKey:@"bloodPressureCloseMax"]];
    [_SPTopLabel setFont:[Tools fontFromFloatValue:20.0]];
    [_SPTopLabel sizeToFit];
    
    _DBPAverageLabel.text=[NSString stringWithFormat:@"%@",[_fristDict objectForKey:@"bloodPressureOpenAvg"]];
    [_DBPAverageLabel setFont:[Tools fontFromFloatValue:20.0]];
    [_DBPAverageLabel sizeToFit];
    
    _DBPTopLabel.text=[NSString stringWithFormat:@"%@",[_fristDict objectForKey:@"bloodPressureOpenMax"]];
    [_DBPTopLabel setFont:[Tools fontFromFloatValue:20.0]];
    [_DBPTopLabel sizeToFit];
    
    [_healthIndex setFont:[Tools fontFromHeightFloatValue:12.0]];
    [_healthIndex sizeToFit];
    [_dspLabelAve setFont:[Tools fontFromHeightFloatValue:12.0]];
    [_dspLabelAve sizeToFit];
    [_spLableAve setFont:[Tools fontFromHeightFloatValue:12.0]];
    [_spLableAve sizeToFit];
    [_dspMaxLable setFont:[Tools fontFromHeightFloatValue:12.0]];
    [_dspMaxLable sizeToFit];
    [_spMaxLable setFont:[Tools fontFromHeightFloatValue:12.0]];
    [_spMaxLable sizeToFit];
    
    [self.measureBtn.titleLabel setFont:[Tools fontFromHeightFloatValue:16.0]];
    
    if ([_downView viewWithTag:1000])
    {
        [[_downView viewWithTag:1000]  removeFromSuperview];
    }
    UIView *gcView =  [[GCView alloc] initGCViewWithBounds:CGRectMake(FRAME_MIN_X(_ringView) -10.0, FRAME_MIN_Y(_ringView), 63.0*MutiValue, 63.0*MutiValue) FromColor:[Tools colorFromHealthIndex:[NSString stringWithFormat:@"%@",[_fristDict  objectForKey:@"healthNumber"]]] ToColor:[UIColor whiteColor] LineWidth:8.0 withPercent:[NSString stringWithFormat:@"%@",[_fristDict  objectForKey:@"healthNumber"]] adjustFont:YES];
    gcView.tag = 1000;
    [_downView addSubview:gcView];
    
    gcView.centerXValue = _healthIndex.centerXValue + 5.0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark  - 按钮点击方法

/**
 *	@brief  三横按钮点击
 */
- (IBAction)ThreeBtnClick:(id)sender
{
    //注册通知事件
    [[NSNotificationCenter defaultCenter] postNotificationName:@"JKSideSlipShow" object:nil userInfo:nil];
    [_starButton  setUserInteractionEnabled:NO];
}
-(void)StarBtnDefaultShow
{
   [_starButton  setUserInteractionEnabled:NO];
}
-(void)StarBtnDefaultHide
{
    [_starButton  setUserInteractionEnabled:YES];
}

/**
 *	@brief	提醒
 */
- (IBAction)alertBtnSelected:(id)sender
{
    TimeReminderViewController *Start=[[TimeReminderViewController alloc]initWithStoryboardID:@"TimeReminderViewController"];
    [self.navigationController pushViewController:Start animated:YES];
}
/**
 *	@brief	开始测量
 */
-(void)AutoConnectFailed
{
    EquipmentSearchViewController *measureView = [[EquipmentSearchViewController alloc] initWithSecondStoryboardID:@"EquipmentSearchViewController"];
    measureView.typeBOOL = YES;
    [self.navigationController pushViewController:measureView animated:YES];
}
-(void)AutoConnectSucceedWith:(CBPeripheral *)currPeripheral writeCharacteristi:(CBCharacteristic *)writeCharacteristic readCharacteristic:(CBCharacteristic *)readCharacteristic SerialNo:(NSString *)SerialNo BabyBlue:(BabyBluetooth *)baby
{
    [currPeripheral setNotifyValue:YES forCharacteristic:readCharacteristic];
    
    BPMeasurementGuidanceViewController *BPMeasurementGuidance=[[BPMeasurementGuidanceViewController alloc]initWithStoryboardID:@"BPMeasurementGuidanceViewController"];
    
    BPMeasurementGuidance.titleStr =NSLocalizedString(@"Blood pressure measurement guide", nil);
    BPMeasurementGuidance.currPeripheral = currPeripheral;
    BPMeasurementGuidance.SerialNo = SerialNo;
    BPMeasurementGuidance.writeCharacteristic = writeCharacteristic;
    BPMeasurementGuidance.readCharacteristic = readCharacteristic;
    BPMeasurementGuidance->baby = baby;
    
    [self.navigationController pushViewController:BPMeasurementGuidance animated:YES];
}

- (IBAction)StartMeaSuringBtnClick:(id)sender
{
    BlueTooth = [[Tools alloc] init];
    BlueTooth.isBPMeasure = YES;
    [BlueTooth babyDelegateBlueTooth:self];
    BlueTooth.delegate = self;
}

@end
