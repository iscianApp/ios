//
//  ViewController.h
//  phoneDrugSieve
//
//  Created by bluemobi on 15/4/28.
//  Copyright (c) 2015年 liuhengyu. All rights reserved.
//
/**
 *	@brief	自定义网络请求基本信息
 */
#ifndef NetWorkDefines_H
#define NetWorkDefines_H
//正式服务器
#define SERVER_DEMAIN @"http://139.196.106.123/lude/"
//测试服务器
//#define SERVER_DEMAIN @"http://112.64.173.178/lude/"
//何小慧
//#define SERVER_DEMAIN @"http://10.58.178.120:8080/lude/"

//郭乐
//#define SERVER_DEMAIN @"http://10.58.178.42:8080/lude/"


//POST 请求最大链接次数
#define MAX_CONNECT_TIMES 5

typedef void (^LLDPNetBaseBlock)(void);

typedef void (^LLDPResponseBlock)(id objectRet, NSError *errorRes);

//永祥 13659260614
//张鹏 18049286528

#endif