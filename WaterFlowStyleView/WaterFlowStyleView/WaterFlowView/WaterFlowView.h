//
//  WaterFlowView.h
//  WaterFlowStyle
//
//  Created by siqin.ljp on 12-5-16.
//  Copyright (c) 2012年 Taobao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WaterFlowViewCell.h"


/* ************************************************** */
@protocol WaterFlowViewDataSource;
@protocol WaterFlowViewDelegate;

@interface WaterFlowView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, assign) id<WaterFlowViewDataSource>     waterFlowDataSource;
@property (nonatomic, assign) id<WaterFlowViewDelegate>       waterFlowDelegate;

- (void)reloadData;
- (WaterFlowViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;

@end


/* ************************************************** */
@protocol WaterFlowViewDataSource <NSObject>

@required
- (NSInteger)waterFlowView:(WaterFlowView *)waterFlowView numberOfRowsInColumn:(NSInteger)column;
- (WaterFlowViewCell *)waterFlowView:(WaterFlowView *)waterFlowView cellForRowAtIndexPath:(WFIndexPath *)indexPath;
- (CGFloat)waterFlowView:(WaterFlowView *)waterFlowView heightForRowAtIndexPath:(WFIndexPath *)indexPath;
- (NSInteger)numberOfColumnsInWaterFlowView:(WaterFlowView *)waterFlowView;

@end


/* ************************************************** */
@protocol WaterFlowViewDelegate <NSObject>
@required
- (void)waterFlowView:(WaterFlowView *)waterFlowView didSelectRowAtIndexPath:(WFIndexPath *)indexPath;

@end
