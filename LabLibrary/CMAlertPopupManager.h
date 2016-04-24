//
//  CMAlertPopupManager.h
//  canmou_c
//
//  Created by JiFeng on 15/11/5.
//  Copyright © 2015年 Canmou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMAlertPopupManager : NSObject

+(CMAlertPopupManager *)sharedManager;
-(void)postTips:(NSString *)title;
-(void)postTips:(NSString *)title withFont:(UIFont *)font;
-(void)loadingTips:(NSString *)title;
@end


@interface CMAlertPopupView : UIView
@property(nonatomic,strong) UILabel     *titleLabel;
@end