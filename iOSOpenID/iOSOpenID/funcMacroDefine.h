//
//  funcMacroDefine.h
//  iOSOpenID
//
//  Created by HRWY on 15/8/13.
//  Copyright (c) 2015年 HRWY. All rights reserved.
//

#ifndef iOSOpenID_funcMacroDefine_h
#define iOSOpenID_funcMacroDefine_h

#ifdef DEBUG
#define OIDLog(fmt, ...) NSLog((@"%s [%d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define OIDLog(...)
#endif

#define Zero                        0
#define ScreenWidth                 [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight                [[UIScreen mainScreen] bounds].size.height



#define IOSOPENIDTOKEN              @"iOSOpenIDToken"
#define KEYFORTOKEN                 @"tk?token="


#define TOOL_BAR_HEIGHT             44
#define NAVIGATION_BAR_HEIGHT       67

//#define SERVER_IP                   @"http://beta.sync4.mobi:8088"
#define SERVER_IP                   @"http://123.125.17.6:8088"


#endif