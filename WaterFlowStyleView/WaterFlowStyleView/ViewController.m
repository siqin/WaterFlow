//
//  ViewController.m
//  WaterFlowStyle
//
//  Created by  on 12-5-16.
//  Copyright (c) 2012年 Taobao. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+OnlineImage.h"

@implementation ViewController

@synthesize waterFlowView = _waterFlowView;
@synthesize dataArray = _dataArray;
@synthesize imageArray = _imageArray;

- (void)dealloc
{
    [_waterFlowView release];
    [_dataArray release];
    [_imageArray release];
    //
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    CGRect rect = self.view.frame;
    rect.size.height -= 50;
    self.waterFlowView = [[WaterFlowView alloc] initWithFrame:rect];
    //self.waterFlowView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:self.waterFlowView];
    self.waterFlowView.waterFlowDataSource = self;
    self.waterFlowView.waterFlowDelegate = self;
    
    rect.origin.x += 100;
    rect.origin.y += self.waterFlowView.frame.size.height + 5;
    rect.size.width = 120;
    rect.size.height = 40;
    UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    moreBtn.frame = rect;
    [moreBtn setTitle:@"Load more" forState:UIControlStateNormal];
    [moreBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.view addSubview:moreBtn];
    [moreBtn addTarget:self action:@selector(addData) forControlEvents:UIControlEventTouchUpInside];
    
    [self initData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.waterFlowView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - 

- (void)initData
{
    self.imageArray = [NSMutableArray arrayWithObjects:
                      @"http://ww1.sinaimg.cn/bmiddle/70e85378jw1dsxriz44iuj.jpg", 
                      @"http://ww2.sinaimg.cn/bmiddle/70e85378jw1ds8g2gtot8j.jpg", 
                      @"http://ww2.sinaimg.cn/large/5f5d4271gw1dt1i8rf47aj.jpg", 
                      @"http://ww4.sinaimg.cn/bmiddle/70e85378jw1dr57belktxj.jpg", 
                      @"http://ww3.sinaimg.cn/bmiddle/70e85378jw1drayzoda5dj.jpg", 
                      nil];
    
    self.dataArray = [NSMutableArray arrayWithCapacity:3];
    for (int i = 0; i < 3; ++i) {
        NSMutableArray *array = [NSMutableArray array];
        [self.dataArray addObject:array];
    }
    
    [self performSelector:@selector(addData)];
}

- (void)addData
{
    for (int i = 0; i < [self.dataArray count]; ++i) {
        NSMutableArray *array = [self.dataArray objectAtIndex:i];
        for (int j = 0; j < 15; ++j) {
            NSInteger randomIndex = arc4random() % [self.imageArray count];
            NSString *imageUrl = [self.imageArray objectAtIndex:randomIndex];
            [array addObject:imageUrl];
        }
    }
    
    [self.waterFlowView reloadData];
}

#pragma mark - WaterFlowViewDataSource

- (NSInteger)waterFlowView:(WaterFlowView *)waterFlowView numberOfRowsInColumn:(NSInteger)column
{
    return [[self.dataArray objectAtIndex:column] count];
}

- (WaterFlowViewCell *)waterFlowView:(WaterFlowView *)waterFlowView cellForRowAtIndexPath:(WFIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"WaterFlowViewCell";
    WaterFlowViewCell *cell = [self.waterFlowView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (nil == cell) {
#ifdef DEBUG
        //NSLog(@"Cell is allocated.\n");
#endif
        cell = [[[WaterFlowViewCell alloc] initWithIdentifier:cellIdentifier] autorelease];
    } else {
#ifdef DEBUG
        //NSLog(@"Cell is reused from reuse-queue.\n");
#endif
    }
    
    NSString *imageUrl = [[self.dataArray objectAtIndex:indexPath.column] objectAtIndex:indexPath.row];
    [cell.imageView setOnlineImage:imageUrl];
    
    if (indexPath.column == 0) {
        cell.backgroundColor = [UIColor redColor];
    } else if (indexPath.column == 1) {
        cell.backgroundColor = [UIColor yellowColor];
    } else {
        cell.backgroundColor = [UIColor blueColor];
    }
    
    return cell;
}

- (CGFloat)waterFlowView:(WaterFlowView *)waterFlowView heightForRowAtIndexPath:(WFIndexPath *)indexPath
{
    float height = 0;
    
	switch ((indexPath.row + indexPath.column )  % 5) {
		case 0:
			height = 127;
			break;
		case 1:
			height = 100;
			break;
		case 2:
			height = 87;
			break;
		case 3:
			height = 114;
			break;
		case 4:
			height = 140;
			break;
		default:
			break;
	}
	
	height += indexPath.row + indexPath.column;
	
	return height;
}

- (NSInteger)numberOfColumnsInWaterFlowView:(WaterFlowView *)waterFlowView
{
    return [self.dataArray count];
}

#pragma mark - WaterFlowViewDelegate

- (void)waterFlowView:(WaterFlowView *)waterFlowView didSelectRowAtIndexPath:(WFIndexPath *)indexPath
{
    ;
}

@end
