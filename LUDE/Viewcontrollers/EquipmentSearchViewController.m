//
//  EquipmentSearchViewController.m
//  LUDE
//
//  Created by bluemobi on 15/10/9.
//  Copyright © 2015年 胡祥清. All rights reserved.
//

#import "EquipmentSearchViewController.h"
#import "ManualBloodPressureViewController.h"
#import "BPMeasurementGuidanceViewController.h"
#import "ScreeningViewController.h"
#import "PeripheralInfo.h"
#import "PeripheralViewCell.h"
//导入.h文件和系统蓝牙库的头文件
#import "BabyBluetooth.h"

#import "MJDIYHeader.h"


@interface EquipmentSearchViewController ()<UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate
>
{
    BOOL succeeBOOL;
    BabyBluetooth *baby;
}

@property (strong, nonatomic) IBOutlet UIButton *btnInput;
@property (strong, nonatomic) IBOutlet UILabel *lblSearchSev;
@property (strong ,nonatomic)NSString *typeStr;
@property (strong ,nonatomic)UIButton *btn;
@property __block NSMutableArray *services;
@property (strong ,nonatomic)NSMutableArray *peripherals;
@property (strong ,nonatomic)NSMutableArray *peripheralsAD;
@property(strong,nonatomic)CBPeripheral *currPeripheral;
@property (nonatomic,strong)CBCharacteristic *writeCharacteristic;
@property (nonatomic,strong)CBCharacteristic *readCharacteristic;
@property (nonatomic ,copy)NSString *SerialNo ;

@end

@implementation EquipmentSearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_lblSearchSev setText:NSLocalizedString(@"Search Device", nil)];
    [_btnInput setTitle:NSLocalizedString(@"Manual Input", nil) forState:UIControlStateNormal];
    if (_typeBOOL == NO)
    {
        _typeStr =NSLocalizedString(@"Blood glucose devices are not connected successfully", nil);
    }
    else
    {
        _typeStr =NSLocalizedString(@"Blood pressure devices are not connected successfully", nil);
    }
    
    [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Ready to open the device", nil)];
    //初始化其他数据 init other
    self.peripherals = [[NSMutableArray alloc]init];
    self.peripheralsAD = [[NSMutableArray alloc]init];
    //初始化
    self.services = [[NSMutableArray alloc]init];
    //初始化BabyBluetooth 蓝牙库
    baby = [BabyBluetooth shareBabyBluetooth];
    //设置蓝牙委托
    [self babyDelegate];
    
    WeakObject(self)
    MJDIYHeader *fresh  = [MJDIYHeader headerWithRefreshingBlock:^{
        [__weakObject.peripherals removeAllObjects];
        //停止之前的连接
        [baby cancelAllPeripheralsConnection];
        //设置委托后直接可以使用，无需等待CBCentralManagerStatePoweredOn状态。
        baby.scanForPeripherals().begin();
        //baby.scanForPeripherals().begin().stop(10);
        [__weakObject.tableView reloadData];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 结束刷新
            [__weakObject.tableView.header endRefreshing];
        });
    }];
    //[fresh setTitle:NSLocalizedString(@"Searching Device", nil) forState:MJRefreshStateRefreshing];
    
    self.tableView.header = fresh;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.tableView.header beginRefreshing];
}
-(void)viewDidAppear:(BOOL)animated{
    NSLog(@"viewDidAppear");
}

-(void)viewWillDisappear:(BOOL)animated{
    NSLog(@"viewWillDisappear");
}

#pragma mark -蓝牙配置和操作
-(void)connectEquipment:(CBPeripheral *)peripheral
{
    //停止扫描
    [baby cancelScan];
    self.currPeripheral = peripheral;
    [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Start connect device", nil)];
    baby.having(peripheral).connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
}

//蓝牙网关初始化和委托方法设置
-(void)babyDelegate{
    
    __weak typeof(self) weakSelf = self;
    
    BabyRhythm *rhythm = [[BabyRhythm alloc]init];
    
    [baby setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
        if (central.state == CBCentralManagerStatePoweredOn) {
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Starts scanning device", nil)];
        }
    }];
    //设置扫描到设备的委托
    [baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        NSLog(@"搜索到了设备:%@\n",peripheral.name);
        
        [weakSelf insertTableView:peripheral advertisementData:advertisementData];
    }];
    //设置设备连接成功的委托
    [baby setBlockOnConnected:^(CBCentralManager *central, CBPeripheral *peripheral) {
        NSLog(@"设备：%@--连接成功",peripheral.name);
        
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
        //保存设备
        weakSelf.currPeripheral = peripheral;
    }];
    //设置设备连接失败的委托
    [baby setBlockOnFailToConnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"设备：%@--连接失败",peripheral.name);
        succeeBOOL = NO;
    }];
    //设置设备断开连接的委托
    [baby setBlockOnDisconnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"设备：%@--断开连接",peripheral.name);
        [weakSelf performSelector:@selector(dismiss:) withObject:nil afterDelay:1];
    }];
    //设置发现设备的Services的委托
    [baby setBlockOnDiscoverServices:^(CBPeripheral *peripheral, NSError *error) {
        for (CBService *service in peripheral.services) {
            NSLog(@"%@:%@",NSLocalizedString(@"Search Service", nil),service.UUID.UUIDString);
            PeripheralInfo *info = [[PeripheralInfo alloc]init];
            [info setServiceUUID:service.UUID];
            info.characteristics = [[NSMutableArray alloc] initWithArray:service.characteristics];
            [weakSelf.services addObject:info];
        }
        [rhythm beats];
    }];
    //设置发现设service的Characteristics的委托
    [baby setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        NSLog(@"===service name:%@",service.UUID);
        int sect = -1;
        for (int i=0;i<self.services.count;i++) {
            PeripheralInfo *info = [weakSelf.services objectAtIndex:i];
            if (info.serviceUUID == service.UUID) {
                sect = i;
            }
        }
        if (sect != -1) {
            PeripheralInfo *info =[weakSelf.services objectAtIndex:sect];
            for (int row=0;row<service.characteristics.count;row++) {
                CBCharacteristic *c = service.characteristics[row];
                [info.characteristics addObject:c];
            }
        }
    }];
    //设置读取characteristics的委托
    [baby setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        NSString *name = [NSString stringWithFormat:@"%@",characteristics.UUID];
        if (_typeBOOL == NO)
        {//血糖
            [weakSelf performSelector:@selector(dismiss:) withObject:nil afterDelay:0.2];
            [weakSelf saveEquipmentToServer:characteristics];
        }
        else
        {
            if ([name isEqualToString:@"Serial Number String"]) {
                [weakSelf performSelector:@selector(dismiss:) withObject:nil afterDelay:0.2];
                NSArray *historyEquipmentArray = [[NTAccount shareAccount] BPEquipments];
                NSMutableArray *EquipmentArray = [[NSMutableArray alloc] initWithArray:historyEquipmentArray];
                if (![EquipmentArray containsObject:peripheral.identifier.UUIDString]) {
                    [EquipmentArray addObject:peripheral.identifier.UUIDString];
                }
                [[NTAccount shareAccount] setBPEquipments:EquipmentArray];
                
                [weakSelf saveEquipmentToServer:characteristics];
            }
            
        }
        
        NSLog(@"characteristic name:%@ value is:%@",characteristics.UUID,  characteristics.value);
    }];
    //设置发现characteristics的descriptors的委托
    [baby setBlockOnDiscoverDescriptorsForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"===characteristic name:%@",characteristic.service.UUID);
        for (CBDescriptor *d in characteristic.descriptors) {
            NSLog(@"CBDescriptor name is :%@",d.UUID);
        }
    }];
    //设置读取Descriptor的委托
    [baby setBlockOnReadValueForDescriptors:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
        NSLog(@"Descriptor name:%@ value is:%@",descriptor.characteristic.UUID, descriptor.value);
    }];
    
    //设置beats break委托
    [rhythm setBlockOnBeatsBreak:^(BabyRhythm *bry) {
        NSLog(@"setBlockOnBeatsBreak call");
        
        //如果完成任务，即可停止beat,返回bry可以省去使用weak rhythm的麻烦
        //        if (<#condition#>) {
        //            [bry beatsOver];
        //        }
        
    }];
    
    //设置beats over委托
    [rhythm setBlockOnBeatsOver:^(BabyRhythm *bry) {
        NSLog(@"setBlockOnBeatsOver call");
    }];
    //设置查找设备的过滤器
    [baby setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName) {
        //设置查找规则是名称大于1 ， the search rule is peripheral.name length > 2
        if (_typeBOOL == NO)
        {//血糖
            if([peripheralName hasPrefix:@"B"])
            {
                return YES;
            }
            return NO;
        }
        else
        {
            if([peripheralName hasPrefix:@"D"])
            {
                return YES;
            }
            return NO;
        }
    }];
    [baby setBlockOnCancelAllPeripheralsConnectionBlock:^(CBCentralManager *centralManager) {
        NSLog(@"setBlockOnCancelAllPeripheralsConnectionBlock");
    }];
    [baby setBlockOnCancelScanBlock:^(CBCentralManager *centralManager) {
        NSLog(@"setBlockOnCancelScanBlock");
    }];
    /*设置babyOptions
     
     参数分别使用在下面这几个地方，若不使用参数则传nil
     - [centralManager scanForPeripheralsWithServices:scanForPeripheralsWithServices options:scanForPeripheralsWithOptions];
     - [centralManager connectPeripheral:peripheral options:connectPeripheralWithOptions];
     - [peripheral discoverServices:discoverWithServices];
     - [peripheral discoverCharacteristics:discoverWithCharacteristics forService:service];
     
     该方法支持channel版本:
     [baby setBabyOptionsAtChannel:<#(NSString *)#> scanForPeripheralsWithOptions:<#(NSDictionary *)#> connectPeripheralWithOptions:<#(NSDictionary *)#> scanForPeripheralsWithServices:<#(NSArray *)#> discoverWithServices:<#(NSArray *)#> discoverWithCharacteristics:<#(NSArray *)#>]
     */
    //示例:
    //扫描选项->CBCentralManagerScanOptionAllowDuplicatesKey:忽略同一个Peripheral端的多个发现事件被聚合成一个发现事件
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    /*连接选项->
     CBConnectPeripheralOptionNotifyOnConnectionKey :当应用挂起时，如果有一个连接成功时，如果我们想要系统为指定的peripheral显示一个提示时，就使用这个key值。
     CBConnectPeripheralOptionNotifyOnDisconnectionKey :当应用挂起时，如果连接断开时，如果我们想要系统为指定的peripheral显示一个断开连接的提示时，就使用这个key值。
     CBConnectPeripheralOptionNotifyOnNotificationKey:
     当应用挂起时，使用该key值表示只要接收到给定peripheral端的通知就显示一个提
     */
    NSDictionary *connectOptions = @{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnNotificationKey:@YES};
    //连接设备->
    [baby setBabyOptionsWithScanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:connectOptions scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
}

- (void)dismiss:(id)sender {
    [SVProgressHUD dismiss];
}
 //保存设备
-(void)saveEquipmentToServer:(CBCharacteristic *)SerialNoCharacteristic
{
    if (_typeBOOL == NO)
    {//血糖
        succeeBOOL =YES;
        [self startWorking];
    }
    else
    {
        if (SerialNoCharacteristic) {
            NSString *SerialNo = [[NSString alloc] initWithData:SerialNoCharacteristic.value encoding:NSUTF8StringEncoding];
            self.SerialNo = SerialNo;
            //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //                         succeeBOOL =YES;
            //                         UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", nil) message: [NSString stringWithFormat:@"%@连接成功",self.currPeripheral.name] delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:@"开始测量", nil];
            //                         alertView.tag = 100;
            //                         [alertView show];});
            succeeBOOL =YES;
            [self startWorking];
        }
        
    }
}
-(void)startWorking
{
    if (_typeBOOL == NO)
    {//血糖
        if (succeeBOOL == YES)
        {//成功
//            CBCharacteristic *writeCBCharacteristic = [BabyToy findCharacteristicFormServices:self.services UUIDString:@"0003CDD2-0000-1000-8000-00805F9B0131"];
//            self.writeCharacteristic = writeCBCharacteristic;
//            CBCharacteristic *readCBCharacteristic = [BabyToy findCharacteristicFormServices:self.services UUIDString:@"0003CDD1-0000-1000-8000-00805F9B0131"];
//            self.readCharacteristic = readCBCharacteristic;
//            
//            if (self.writeCharacteristic && self.readCharacteristic) {
//                StartDetectionViewController *Start=[[StartDetectionViewController alloc]initWithStoryboardIDWithLHY:@"StartDetectionViewController" storyboardName:@"measure"];
//                Start.titleStr =@"血糖测量指导";
//                Start.currPeripheral = self.currPeripheral;
//                Start.SerialNo = self.SerialNo;
//                Start.writeCharacteristic = self.writeCharacteristic;
//                Start.readCharacteristic = self.readCharacteristic;
//                Start->baby = self->baby;
//                [self.navigationController pushViewController:Start animated:YES];
//            }
        }
        else
        {//手动输入
//            ManualBloodGlucoseViewController *Start=[[ManualBloodGlucoseViewController alloc]initWithStoryboardIDWithLHY:@"ManualBloodGlucoseViewController" storyboardName:@"measure"];
//            Start.currPeripheral = self.currPeripheral;
//            [self.navigationController pushViewController:Start animated:YES];
        }
    }
    else
    {//血压
        if (succeeBOOL == YES)
        {//成功
//            for (CBService *s in self.services) {
//                for (CBCharacteristic *c in s.characteristics) {
//                  
//                    NSLog(@"\n\n\n\n\n%lu",(unsigned long)c.properties);
//                    
//                }
//            }
            
            CBCharacteristic *writeCBCharacteristic = [BabyToy findCharacteristicFormServices:self.services UUIDString:@"FFF2"];
            self.writeCharacteristic = writeCBCharacteristic;
            CBCharacteristic *readCBCharacteristic = [BabyToy findCharacteristicFormServices:self.services UUIDString:@"FFF1"];
            self.readCharacteristic = readCBCharacteristic;
            
            if (self.writeCharacteristic && self.readCharacteristic) {
                
                 [self.currPeripheral setNotifyValue:YES forCharacteristic:self.readCharacteristic];
                
                BPMeasurementGuidanceViewController *BPMeasurementGuidance=[[BPMeasurementGuidanceViewController alloc]initWithStoryboardID:@"BPMeasurementGuidanceViewController"];
                
                BPMeasurementGuidance.titleStr =NSLocalizedString(@"Blood pressure measurement guide", nil);
                BPMeasurementGuidance.currPeripheral = self.currPeripheral;
                BPMeasurementGuidance.SerialNo = self.SerialNo;
                BPMeasurementGuidance.writeCharacteristic = self.writeCharacteristic;
                BPMeasurementGuidance.readCharacteristic = self.readCharacteristic;
                BPMeasurementGuidance->baby = self->baby;
                
                [self.navigationController pushViewController:BPMeasurementGuidance animated:YES];
            }
        }
        else
        {//手动输入
            ManualBloodPressureViewController *Start=[[ManualBloodPressureViewController alloc] initWithSecondStoryboardID:@"ManualBloodPressureViewController"];
            Start.currPeripheral = self.currPeripheral;
            [self.navigationController pushViewController:Start animated:YES];
        }
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        //停止之前的连接
        [baby cancelAllPeripheralsConnection];
        //设置委托后直接可以使用，无需等待CBCentralManagerStatePoweredOn状态。
        baby.scanForPeripherals().begin();
        return;
    }
    else
    {
        [self startWorking];
    }
}
#pragma mark -UIViewController 方法
//插入table数据
-(void)insertTableView:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData{
    if(![self.peripherals containsObject:peripheral]){
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.peripherals.count inSection:0];
        [indexPaths addObject:indexPath];
        [self.peripherals addObject:peripheral];
        [self.peripheralsAD addObject:advertisementData];
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self.tableView reloadData];
    }
}
#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.peripherals.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50.0;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *backView =[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH - 20.0, 50.0)];
    [backView setBackgroundColor:[UIColor whiteColor]];
    //底线
    UIView *blueLinesView =[[UIView alloc]initWithFrame:CGRectMake(0, 49.0, SCREENWIDTH - 20.0, 1.0)];
    blueLinesView.backgroundColor =[UIColor colorWithRed:0 green:0.63857647 blue:0.936317647 alpha:1];
    [backView addSubview:blueLinesView];
    //图片
    UIImageView *spImage=[[UIImageView alloc]initWithFrame:CGRectMake(0.0, 15.0, 5, 20.0)];
    spImage.image =[UIImage imageNamed:@"blueduanxian"];
    [backView addSubview:spImage];
    //设备信息
    UILabel *allLabel =[[UILabel alloc]initWithFrame:CGRectMake(10.0, 10.0,  SCREENWIDTH - 30.0 ,30.0)];
    allLabel.font =[UIFont systemFontOfSize:16];
    allLabel.textColor =[UIColor blackColor];
    [allLabel setTextAlignment:NSTextAlignmentCenter];

    if (self.peripherals.count  == 0) {
       allLabel.text = NSLocalizedString(@"No available set was found for the time being", nil);
    }
    else
    {
        allLabel.text = NSLocalizedString(@"Find the following devices please select the connection", nil);
    }
    [backView addSubview:allLabel];
    return backView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"PeripheralViewCell";
    PeripheralViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[PeripheralViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier
                ];
    }
    CBPeripheral *peripheral = [self.peripherals objectAtIndex:indexPath.row];
    [cell.peripheralLabel setText:peripheral.name];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //停止扫描
    [baby cancelScan];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Ready to connect equipment", nil)];
    CBPeripheral *peripheral =  [self.peripherals objectAtIndex:indexPath.row];
    self.currPeripheral = peripheral;
    [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Start connect device", nil)];
    baby.having(peripheral).connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/**
 *	@brief 返回按钮点击事件
 */
- (IBAction)returnBtnClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
/**
 *	@brief 手动输入点击事件
 */
- (IBAction)mannueInputDataBtnSelected:(UIButton *)sender {
    ManualBloodPressureViewController *Start=[[ManualBloodPressureViewController alloc] initWithSecondStoryboardID:@"ManualBloodPressureViewController"];
    Start.currPeripheral = self.currPeripheral;
    [self.navigationController pushViewController:Start animated:YES];
}
@end
