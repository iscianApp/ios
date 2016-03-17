//
//  Tools.h
//  LUDE
//
//  Created by 胡祥清 on 15/10/7.
//  Copyright © 2015年 胡祥清. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVProgressHUD.h"
#import "Reachability.h"
#import "AppDelegate.h"
#import "PeripheralInfo.h"
//导入.h文件和系统蓝牙库的头文件
#import "BabyBluetooth.h"
#import "NTAccount.h"

#define MsgBox(msg) [self MsgBox:msg]

@protocol AutoConnectSucceed <NSObject>

-(void)AutoConnectSucceedWith:(CBPeripheral *)currPeripheral writeCharacteristi:(CBCharacteristic *)writeCharacteristic readCharacteristic:(CBCharacteristic *)readCharacteristic SerialNo:(NSString *)SerialNo BabyBlue:(BabyBluetooth *)baby;
-(void)AutoConnectFailed;
@end

@interface Tools : NSObject
{
@public
    BOOL succeeBOOL;
    BabyBluetooth *baby;
}

@property (nonatomic ,assign)BOOL isBPMeasure;
@property (nonatomic ,assign)BOOL hasSearched;
@property __block NSMutableArray *services;
@property (strong ,nonatomic)NSMutableArray *peripherals;
@property (strong ,nonatomic)NSMutableArray *peripheralsAD;
@property(strong,nonatomic)CBPeripheral *currPeripheral;
@property (nonatomic,strong)CBCharacteristic *writeCharacteristic;
@property (nonatomic,strong)CBCharacteristic *readCharacteristic;
@property (nonatomic ,copy)NSString *SerialNo ;

@property (nonatomic ,assign) __block int countNumber;

@property (nonatomic ,assign)id<AutoConnectSucceed>delegate;


id objectFromJSONData(NSData *data, NSError **error);

NSString * JSONStringFromObject(id object, NSError ** error);

BOOL StringIsValid(NSString *string);
NSString * CompareCurrentTime(NSDate *compareDate);

+ (CGFloat)getAdapterHeight;
+ (void)MsgBox:(NSString *)msg;
+ (void)show ;
+(void)dismiss ;

+ (void) OpenUrl:(NSString *)inUrl;
+ (UIImage *)createImageWithColor:(UIColor *)color;

+(BOOL) isTextViewNotEmpty:(NSString *) text isCue:(BOOL) isCue;


+(BOOL) isValidateMobile:(NSString *)mobile;
//验证邮箱的合法性
+(BOOL)isValidateEmail:(NSString *)email;

+(NSInteger) ageFromDate:(NSString *) dateStr;
//+(ErrorCode) errorCodeWithKey:(NSString *) errorCodeKey;

/**
 *	@brief	=====横向、纵向移动===========
 */
-(CABasicAnimation *)moveX:(float)time X:(NSNumber *)x;
-(CABasicAnimation *)moveY:(float)time Y:(NSNumber *)Y;

/**
 *@brief 把当前页转成Image
 */
+ (UIImage *)createImageWithView:(UIView *)view;
/**
 *@brief 可以直接使用十六进制设置控件的颜色，而不必通过除以255.0进行转换
 */
+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;
//默认alpha值为1
+ (UIColor *)colorWithHexString:(NSString *)color;

/**
 *@brief 根据收缩压和舒张压设置颜色
 */
+ (UIColor *)colorFromSPValue:(NSInteger )SPValue DSPValue:(NSInteger )DSPValue;
/**
 *@brief 根据健康指数设置颜色
 */
+ (UIColor *)colorFromHealthIndex:(id)healthIndex;
/**
 *@brief 打开蓝牙搜索设备，若有连过的则直接连
 */
-(void)babyDelegateBlueTooth:(id)object;

/**
 *@brief 根据不同屏幕显示字体
 */
+ (NSString*)deviceString;
+(UIFont *)fontFromFloatValue:(CGFloat)number;
+(UIFont *)fontFromHeightFloatValue:(CGFloat)number;
@end
