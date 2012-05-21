//
//  WaterFlowViewCell.h
//  WaterFlowStyle
//
//  Created by siqin.ljp on 12-5-16.
//  Copyright (c) 2012年 Taobao. All rights reserved.
//

#import <UIKit/UIKit.h>


/* ************************************************** */
@class WFIndexPath;

@interface WaterFlowViewCell : UIView

@property (nonatomic, retain) NSString      *reuseIdentifier;
@property (nonatomic, retain) WFIndexPath   *indexPath;

@property (nonatomic, retain) UIImageView   *imageView;

-(id)initWithIdentifier:(NSString *)identifier;

@end


/* ************************************************** */
@interface WFIndexPath : NSObject

+ (WFIndexPath *)indexPathForRow:(NSInteger)row inColumn:(NSInteger)column;

@property (nonatomic) NSInteger column;
@property (nonatomic) NSInteger row;

@end