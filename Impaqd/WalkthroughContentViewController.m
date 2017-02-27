//
//  WalkthroughContentViewController.m
//  Impaqd
//
//  Created by Lars Emil Lamm Nielsen on 6/24/14.
//  Copyright (c) 2014 Impaqd. All rights reserved.
//

#import "WalkthroughContentViewController.h"
#import <Mixpanel/Mixpanel.h>

@interface WalkthroughContentViewController ()

@end

@implementation WalkthroughContentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleLabel.text = self.titleTextHolder;
    self.contentText.text = self.contentTextHolder;
    self.contentImage.image = [UIImage imageNamed:self.imageNameHolder];
    
    //Bug in xcode. 
    self.contentText.selectable = false;
    
    if(!self.lastScreen){
        self.registerButton.hidden = true;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)registerAction:(id)sender {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Register" bundle:nil];
    UIViewController *mainVC = [storyBoard instantiateInitialViewController];
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    [window setRootViewController:mainVC];

    //ANALYTICS START
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"clicked register button"];
    //ANALYTICS END
}
@end
