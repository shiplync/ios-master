//
//  WalkthroughRootViewController.m
//  Impaqd
//
//  Created by Lars Emil Lamm Nielsen on 6/24/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import "WalkthroughRootViewController.h"
#import "AppDelegate.h"


@interface WalkthroughRootViewController ()

@end

@implementation WalkthroughRootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Inherited from registration flow
    self.existingAccountCheckLabel.hidden = NO;
    self.existingAccountCheckIndicator.hidden = NO;
    self.welcomeImage.image = [UIImage imageNamed:@"welcome_logo"];
    
    // wait 6s for the user account to be pulled down from iCloud
    double delayInSeconds = 6.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.existingAccountCheckLabel.hidden = YES;
        self.existingAccountCheckIndicator.hidden = YES;
        self.welcomeImage.hidden = true;
        // Create page view controller
        self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"walkthroughPageViewController"];
        self.pageViewController.dataSource = self;
        
        WalkthroughContentViewController *startingViewController = [self viewControllerAtIndex:0];
        NSArray *viewControllers = @[startingViewController];
        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        
        // Change the size of page view controller
        self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 30);
        
        [self addChildViewController:_pageViewController];
        [self.view addSubview:_pageViewController.view];
        [self.pageViewController didMoveToParentViewController:self];
    });
    
	// Create the data model
    _pageTitles = @[@"Welcome to Traansmission!",
                    @"Register",
                    @"Search",
                    @"Accept",
                    @"Lets get started!"];
    
    _pageContent = @[@"Traansmission connects truckers and shippers so truckers don’t have to spend time looking for their next job.",
                     
                     @"It’s free and take less than 1 minute.",
                     
                     @"Once you have been approved (takes a couple of hours), you can search for shipments near you.",
                     
                     @"When you see a job you like, simply call the shipper to accept you.",

                     @""];
    
    _pageImageNames = @[@"welcome_logo",
                    @"walkthrough2",
                    @"walkthrough3",
                    @"walkthrough4",
                    @"welcome_logo"];
    

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (WalkthroughContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    WalkthroughContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"walkthroughContentViewController"];
    pageContentViewController.titleTextHolder = self.pageTitles[index];
    pageContentViewController.contentTextHolder = self.pageContent[index];
        pageContentViewController.imageNameHolder = self.pageImageNames[index];
    pageContentViewController.pageIndex = index;
    if (index == [self.pageTitles count]-1) {
            pageContentViewController.lastScreen = true;
    }else{
            pageContentViewController.lastScreen = false;
    }

    
    return pageContentViewController;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((WalkthroughContentViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((WalkthroughContentViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageTitles count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.pageTitles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}


@end
