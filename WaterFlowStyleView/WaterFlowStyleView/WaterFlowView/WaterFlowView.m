//
//  WaterFlowView.m
//  WaterFlowStyle
//
//  Created by siqin.ljp on 12-5-16.
//  Copyright (c) 2012年 Taobao. All rights reserved.
//

#import "WaterFlowView.h"

#define WFColumnSpace           (5.0f) // The space between columns
#define WFColumnWidth           ((self.frame.size.width - (self.columns - 1) * WFColumnSpace) / self.columns)

#define WFCellSpace             (3.0f) // The space between cells
#define WFCellWidth             WFColumnWidth


/* ************************************************** */
@interface WaterFlowView ()

@property (nonatomic) NSUInteger columns;

@property (nonatomic, retain) NSMutableArray        *cellRectArray;
@property (nonatomic, retain) NSMutableArray        *visibleCells;

@property (nonatomic, retain) NSMutableDictionary   *reuseDict;

- (void)initialize;
- (void)onScroll;

- (BOOL)canRemoveCellForRect:(CGRect)rect;
- (BOOL)containVisibleCellForIndexPath:(WFIndexPath *)indexPath;
- (void)addReusableCell:(WaterFlowViewCell *)cell;

@end


/* ************************************************** */
@implementation WaterFlowView

@synthesize waterFlowDataSource = _waterFlowDataSource;
@synthesize waterFlowDelegate = _waterFlowDelegate;

@synthesize columns = _columns;

@synthesize cellRectArray = _cellRectArray;
@synthesize visibleCells = _visibleCells;

@synthesize reuseDict = _reuseDict;

#pragma mark - WaterFlowView Lifecycle

- (void)dealloc
{
    [_cellRectArray release];
    [_visibleCells release];
    
    [_reuseDict release];
    
    //
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.delegate = self;
    }
    return self;
}

#pragma mark - WaterFlowView Interface

- (void)reloadData
{
    if (self.visibleCells && [self.visibleCells count] > 0) {
        for (int i = 0; i < [self.visibleCells count]; ++i) {
            NSMutableArray *singleVisibleArray = [self.visibleCells objectAtIndex:i];
            if (!singleVisibleArray || 0 == [singleVisibleArray count]) continue;
            
            int visibleCellCount = [singleVisibleArray count];
            for (int j; j < visibleCellCount; ++j) {
                WaterFlowViewCell *cell = [singleVisibleArray objectAtIndex:j];
                [self addReusableCell:cell];
                if (cell.superview) [cell removeFromSuperview];
            }
        }
    }
    
    [self initialize];
}

- (WaterFlowViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    if (nil == identifier || 0 == identifier.length) {
        return nil;
    }
    
    NSMutableArray *reuseQueue = [self.reuseDict objectForKey:identifier];
	if(reuseQueue && [reuseQueue isKindOfClass:[NSArray class]] && reuseQueue.count > 0) {
		WaterFlowViewCell *cell = [reuseQueue lastObject];
		[[cell retain] autorelease];
		[reuseQueue removeLastObject];
        
		return cell;
	}
    
    return nil;
}

#pragma mark - Private Methods

- (void)initialize
{
    self.columns = [self.waterFlowDataSource numberOfColumnsInWaterFlowView:self];
    self.reuseDict = [NSMutableDictionary dictionaryWithCapacity:10];
    
    // Save all the rectangles & the visible cells for each column
    self.cellRectArray = [NSMutableArray arrayWithCapacity:self.columns];
    self.visibleCells = [NSMutableArray arrayWithCapacity:self.columns];
    
    CGFloat scrollHeight = 0.0f;
    
    for (int i = 0; i < self.columns; ++i) {
        [self.visibleCells addObject:[NSMutableArray array]];
        
        NSMutableArray *singleRectArray = [NSMutableArray array];
        NSUInteger rows = [self.waterFlowDataSource waterFlowView:self numberOfRowsInColumn:i];
        
        CGFloat heightTillNow = 0.0f;
        CGFloat originX = self.frame.origin.x + i * (WFColumnWidth + WFColumnSpace);
        
        for (int j = 0; j < rows; ++j) {
            CGFloat originY = heightTillNow;
            
            CGFloat height = [self.waterFlowDataSource waterFlowView:self heightForRowAtIndexPath:[WFIndexPath indexPathForRow:j inColumn:i]];
            
            heightTillNow += (height + WFCellSpace);
            
            CGRect rect = CGRectMake(originX, originY, WFCellWidth, height);
            [singleRectArray addObject:[NSValue valueWithCGRect:rect]];
        }
        
        scrollHeight = (heightTillNow >= scrollHeight) ? heightTillNow : scrollHeight;
        [self.cellRectArray addObject:singleRectArray];
    }
    
    self.contentSize = CGSizeMake(self.frame.size.width, scrollHeight);
    
    [self onScroll];
}

- (void)onScroll
{
    for (int i = 0; i < self.columns; ++i) {
        NSUInteger basicVisibleRow = 0;
        WaterFlowViewCell *cell = nil;
        CGRect cellRect = CGRectZero;
        
        NSMutableArray *singleRectArray = [self.cellRectArray objectAtIndex:i];
        NSMutableArray *singleVisibleArray = [self.visibleCells objectAtIndex:i];
        
        if (0 == [singleVisibleArray count]) {
            // There is no visible cells in current column now, find one.
            for (int j = 0; j < [singleRectArray count]; ++j) {
                cellRect = [(NSValue *)[singleRectArray objectAtIndex:j] CGRectValue];
                if (![self canRemoveCellForRect:cellRect]) {
                    WFIndexPath *indexPath = [WFIndexPath indexPathForRow:j inColumn:i];
                    basicVisibleRow = j;
                    
                    cell = [self.waterFlowDataSource waterFlowView:self cellForRowAtIndexPath:indexPath]; // nil ?
                    cell.indexPath = indexPath;
                    cell.frame = cellRect;
                    if (!cell.superview) [self addSubview:cell];
                    NSLog(@"Cell Info : %@\n", cell);
                    
                    [singleVisibleArray insertObject:cell atIndex:0];
                    break;
                }
            }
        } else {
            cell = [singleVisibleArray objectAtIndex:0];
            basicVisibleRow = cell.indexPath.row;
        }
        
        // Look back to load visible cells
        for (int j = basicVisibleRow - 1; j >= 0; --j) {
            cellRect = [(NSValue *)[singleRectArray objectAtIndex:j] CGRectValue];
            if (![self canRemoveCellForRect:cellRect]) {
                WFIndexPath *indexPath = [WFIndexPath indexPathForRow:j inColumn:i];
                if ([self containVisibleCellForIndexPath:indexPath]) {
                    continue ;
                }
                
                cell = [self.waterFlowDataSource waterFlowView:self cellForRowAtIndexPath:indexPath]; // nil ?
                cell.indexPath = indexPath;
                cell.frame = cellRect;
                if (!cell.superview) [self addSubview:cell];
                NSLog(@"Cell Info : %@\n", cell);
                
                [singleVisibleArray insertObject:cell atIndex:0];
            } else {
                break;
            }
        }
        
        // Look forward to load visible cells
        for (int j = basicVisibleRow + 1; j < [singleRectArray count]; ++j) {
            cellRect = [(NSValue *)[singleRectArray objectAtIndex:j] CGRectValue];
            if (![self canRemoveCellForRect:cellRect]) {
                WFIndexPath *indexPath = [WFIndexPath indexPathForRow:j inColumn:i];
                if ([self containVisibleCellForIndexPath:indexPath]) {
                    continue ;
                }
                
                cell = [self.waterFlowDataSource waterFlowView:self cellForRowAtIndexPath:indexPath]; // nil ?
                cell.indexPath = indexPath;
                cell.frame = cellRect;
                if (!cell.superview) [self addSubview:cell];
                NSLog(@"Cell Info : %@\n", cell);
                
                [singleVisibleArray insertObject:cell atIndex:0];
            } else {
                break;
            }
        }
        
        // Recycle invisible cells
        for (int j = 0; j < [singleVisibleArray count]; ++j) {
            cell = [singleVisibleArray objectAtIndex:j];
            if ([self canRemoveCellForRect:cell.frame]) {
                [cell removeFromSuperview];
                [self addReusableCell:cell];
                [singleVisibleArray removeObject:cell];
                --j;
                NSLog(@"Removable Cell Info : %@\n", cell);
            }
        }
    }
}

- (BOOL)canRemoveCellForRect:(CGRect)rect
{
    CGPoint offset = [self contentOffset];
    
    if (rect.origin.y + rect.size.height < offset.y
        || rect.origin.y > (offset.y + self.frame.size.height)) {
        return YES;
    }
    
    return NO;
}

- (BOOL)containVisibleCellForIndexPath:(WFIndexPath *)indexPath
{
    NSArray *singleVisibleArray = [self.visibleCells objectAtIndex:indexPath.column];
    for (int i = 0; i < [singleVisibleArray count]; ++i) {
        WaterFlowViewCell *cell = [singleVisibleArray objectAtIndex:i];
        if (cell.indexPath.row == indexPath.row) {
            return YES;
        }
    }
    return NO;
}

- (void)addReusableCell:(WaterFlowViewCell *)cell
{
    if (nil == cell.reuseIdentifier || 0 == cell.reuseIdentifier.length) {
        return ;
    }
    
    NSMutableArray *reuseQueue = [self.reuseDict objectForKey:cell.reuseIdentifier];
    
    if(nil == reuseQueue) {
        reuseQueue = [NSMutableArray arrayWithObject:cell];
        [self.reuseDict setObject:reuseQueue forKey:cell.reuseIdentifier];
    } else {
        [reuseQueue addObject:cell];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self onScroll];
    
    if ([self.waterFlowDelegate conformsToProtocol:@protocol(UIScrollViewDelegate)] &&
        [self.waterFlowDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [(id<UIScrollViewDelegate>)self.waterFlowDelegate scrollViewDidScroll:self];
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    return YES;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    ;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self onScroll];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    ;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([self.waterFlowDelegate conformsToProtocol:@protocol(UIScrollViewDelegate)] &&
        [self.waterFlowDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [(id<UIScrollViewDelegate>)self.waterFlowDelegate scrollViewDidEndDragging:self willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    ;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    ;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    ;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    ;
}

@end
