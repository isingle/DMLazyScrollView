//
//  DMViewController.m
//  DMLazyScrollViewExample
//
//  Created by Daniele Margutti (me@danielemargutti.com) on 24/11/12.
//  Copyright (c) 2012 http://www.danielemargutti.com. All rights reserved.
//

#import "DMViewController.h"
#import "DMLazyScrollView.h"

#define ARC4RANDOM_MAX	0x100000000


@interface DMViewController () <DMLazyScrollViewDelegate> {
    DMLazyScrollView* lazyScrollView;
    NSMutableArray*    viewControllerArray;
    NSMutableArray *viewArrs;
    NSUInteger numberOfPages;
}
@end

@implementation DMViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    viewArrs = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 10; i ++) {
        UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 300, 300)];
        view1.backgroundColor = [UIColor whiteColor];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 100, 40)];
        label.text = [NSString stringWithFormat:@"%d",i];
        [view1 addSubview:label];
        [viewArrs addObject:view1];
    }
    
    // PREPARE PAGES
    numberOfPages = 10;
    viewControllerArray = [[NSMutableArray alloc] initWithCapacity:numberOfPages];
    for (NSUInteger k = 0; k < numberOfPages; ++k) {
        [viewControllerArray addObject:[NSNull null]];
    }
    
    // PREPARE LAZY VIEW
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-50);
    lazyScrollView = [[DMLazyScrollView alloc] initWithFrame:rect];
    [lazyScrollView setEnableCircularScroll:YES];//设置循环滚动
    [lazyScrollView setAutoPlay:YES];//设置自动滚动
    
    __weak __typeof(&*self)weakSelf = self;
    lazyScrollView.dataSource = ^(NSUInteger index) {
        return [weakSelf controllerAtIndex:index];
    };
    lazyScrollView.numberOfPages = numberOfPages;
    lazyScrollView.assignOfPages = 0;//从指定页开始加载页面
    lazyScrollView.controlDelegate = self;
    [self.view addSubview:lazyScrollView];
    
    // MOVE BY 3 FORWARD
    UIButton*btn_moveForward = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn_moveForward setTitle:@"MOVE BY 3" forState:UIControlStateNormal];
    [btn_moveForward addTarget:self action:@selector(btn_moveForward:) forControlEvents:UIControlEventTouchUpInside];
    [btn_moveForward setFrame:CGRectMake(self.view.frame.size.width/2.0f,lazyScrollView.frame.origin.y+lazyScrollView.frame.size.height+5, 320/2.0f,40)];
    [self.view addSubview:btn_moveForward];
    
    // MOVE BY -3 BACKWARD
    UIButton*btn_moveBackward = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn_moveBackward setTitle:@"MOVE BY -3" forState:UIControlStateNormal];
    [btn_moveBackward addTarget:self action:@selector(btn_moveBack:) forControlEvents:UIControlEventTouchUpInside];
    [btn_moveBackward setFrame:CGRectMake(0,lazyScrollView.frame.origin.y+lazyScrollView.frame.size.height+5, 320/2.0f,40)];
    [self.view addSubview:btn_moveBackward];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void) btn_moveBack:(id) sender {
    [lazyScrollView moveByPages:-3 animated:YES];
}

- (void) btn_moveForward:(id) sender {
    [lazyScrollView moveByPages:3 animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    
}

- (UIViewController *) controllerAtIndex:(NSInteger) index {
    if (index > viewControllerArray.count || index < 0) return nil;
    id res = [viewControllerArray objectAtIndex:index];
    if (res == [NSNull null]) {
        UIViewController *contr = [[UIViewController alloc] init];
        contr.view.backgroundColor = [UIColor colorWithRed: (CGFloat)arc4random()/ARC4RANDOM_MAX
                                                      green: (CGFloat)arc4random()/ARC4RANDOM_MAX
                                                       blue: (CGFloat)arc4random()/ARC4RANDOM_MAX
                                                     alpha: 1.0f];
        
        UILabel* label = [[UILabel alloc] initWithFrame:contr.view.bounds];
        label.backgroundColor = [UIColor clearColor];
        label.text = [NSString stringWithFormat:@"%d",index];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:50];
//        [contr.view addSubview:label];
        UIView *pv = [viewArrs objectAtIndex:index];
        [pv addSubview:label];
        [contr.view addSubview:pv];
        
        [viewControllerArray replaceObjectAtIndex:index withObject:contr];
        return contr;
    }
    return res;
}

- (void)lazyScrollView:(DMLazyScrollView *)pagingView currentPageChanged:(NSInteger)currentPageIndex
{
    //优化内存，始终保存三页vc
    NSLog(@"viewarray===%@",viewControllerArray);
    for (NSInteger i = 0; i < numberOfPages; i++) {
        if (i == currentPageIndex || i == currentPageIndex+1 || i == currentPageIndex-1) {
            continue;
        }
        id res = [viewControllerArray objectAtIndex:i];
        if (res != [NSNull null]) {
            UIViewController *vc = (UIViewController *)res;
            [vc.view  removeFromSuperview];
            vc = nil;
            [viewControllerArray replaceObjectAtIndex:i withObject:[NSNull null]];
            
        }
    }
    NSLog(@"viewarray===%@",viewControllerArray);
    
    //end
}
/*
- (void)lazyScrollViewDidEndDragging:(DMLazyScrollView *)pagingView {
    NSLog(@"Now visible: %@",lazyScrollView.visibleViewController);
}
*/
@end
