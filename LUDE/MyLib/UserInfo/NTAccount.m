//
//  NTAccount.m
//  LUDE
//
//  Created by 胡祥清 on 15/10/8.
//  Copyright © 2015年 胡祥清. All rights reserved.
//

#import "NTAccount.h"

static NTAccount *_share_account = nil;

@implementation NTAccount

+ (instancetype)shareAccount{
    if (_share_account == nil) {
        _share_account = [[NTAccount alloc] init];
    }
    return _share_account;
}

- (instancetype) init
{
    self = [super init];
    if (self) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        _baseLocalPath = paths[0];
    }
    return self;
}
-(void)setMessages:(NSArray *)Messages
{
    if ([Messages isKindOfClass:[NSArray class]] && Messages != nil) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:Messages];
        [defaults setObject:data forKey:@"Messages"];
        [defaults synchronize];
    }
}
-(NSArray *)Messages
{
    NSArray *Messages = nil;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:@"Messages"];
    if (data)
    {
        Messages = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return Messages;
}

-(void)setBPEquipments:(NSArray *)BPEquipments
{
    if ([BPEquipments isKindOfClass:[NSArray class]] && BPEquipments != nil) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:BPEquipments];
        [defaults setObject:data forKey:@"BPEquipments"];
        [defaults synchronize];
    }
}
-(NSArray *)BPEquipments
{
    NSArray *BPEquipments = nil;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:@"BPEquipments"];
    if (data)
    {
        BPEquipments = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return BPEquipments;
}
-(void)setBSEquipments:(NSArray *)BSEquipments
{
    if ([BSEquipments isKindOfClass:[NSArray class]] && BSEquipments != nil) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:BSEquipments];
        [defaults setObject:data forKey:@"BSEquipments"];
        [defaults synchronize];
    }
}
-(NSArray *)BSEquipments
{
    NSArray *BSEquipments = nil;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:@"BSEquipments"];
    if (data)
    {
        BSEquipments = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return BSEquipments;
}

-(void)setScreenType:(NSString *)ScreenType
{
    if ([ScreenType isKindOfClass:[NSString class]] && ScreenType != nil) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:ScreenType forKey:@"ScreenType"];
        [defaults synchronize];
    }
}
-(NSString *)ScreenType
{
    NSString *ScreenType = nil;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    ScreenType = [defaults objectForKey:@"ScreenType"];
    return ScreenType;
}
@end

