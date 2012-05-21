//
//  ViewController.h
//  WaterFlowStyle
//
//  Created by  on 12-5-16.
//  Copyright (c) 2012年 Taobao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WaterFlowView.h"

@interface ViewController : UIViewController <WaterFlowViewDelegate, WaterFlowViewDataSource>

@property (nonatomic, retain) WaterFlowView *waterFlowView;

@property (nonatomic, retain) NSMutableArray *dataArray;
@property (nonatomic, retain) NSMutableArray *imageArray;

- (void)initData;

@end
