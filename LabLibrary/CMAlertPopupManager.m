//
//  CMAlertPopupManager.m
//  canmou_c
//
//  Created by JiFeng on 15/11/5.
//  Copyright © 2015年 Canmou. All rights reserved.
//

#import "CMAlertPopupManager.h"

@interface CMAlertPopupManager ()

@end

@implementation CMAlertPopupManager

+(CMAlertPopupManager *)sharedManager{
    static CMAlertPopupManager * managerInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        managerInstance = [[CMAlertPopupManager alloc] init];
    });
    
    return managerInstance;
}

-(void)postTips:(NSString *)title{
    [self postTips:title withFont:[UIFont systemFontOfSize:18.0]];
}
-(void)postTips:(NSString *)title withFont:(UIFont *)font{
    CMAlertPopupView *popupView = [[CMAlertPopupView alloc] initWithFrame:CGRectMake(0, 0, 255, 100)];
    popupView.titleLabel.text = title;
    popupView.titleLabel.font = font;
    KLCPopup *pop = [KLCPopup popupWithContentView:popupView
                                          showType:KLCPopupShowTypeGrowIn
                                       dismissType:KLCPopupDismissTypeGrowOut
                                          maskType:KLCPopupMaskTypeDimmed
                          dismissOnBackgroundTouch:NO
                             dismissOnContentTouch:NO];
    [pop showWithDuration:1.0];
}

-(void)loadingTips:(NSString *)title{
    CMAlertPopupView *popupView = [[CMAlertPopupView alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
    popupView.titleLabel.text = title;
    KLCPopup *pop = [KLCPopup popupWithContentView:popupView
                                          showType:KLCPopupShowTypeGrowIn
                                       dismissType:KLCPopupDismissTypeGrowOut
                                          maskType:KLCPopupMaskTypeDimmed
                          dismissOnBackgroundTouch:NO
                             dismissOnContentTouch:NO];
    [pop show];
}

@end


@interface CMAlertPopupView ()


@end

@implementation CMAlertPopupView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        _titleLabel = [[UILabel alloc] initWithFrame:frame];
//        _titleLabel.font = [UIFont systemFontOfSize:18.0];
        _titleLabel.textColor = kUIColorFromRGB(0x3b3b3b);
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
        
        self.layer.cornerRadius = 4.0;
        self.layer.masksToBounds = YES;
    }
    return self;
}

@end
