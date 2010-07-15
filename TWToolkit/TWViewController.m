//
//  TWViewController.m
//  TWToolkit
//
//  Created by Sam Soffes on 7/14/10.
//  Copyright 2010 Tasteful Works. All rights reserved.
//

#import "TWViewController.h"
#import "UIImage+BundleImage.h"
#import "UIView+fading.h"
#import <QuartzCore/QuartzCore.h>

@implementation TWViewController

@synthesize modalParentViewController = _modalParentViewController;
@synthesize customModalViewController = _customModalViewController;

#pragma mark NSObject

- (void)dealloc {
	[_customModalViewController release];
	[_modalContainerView release];
	[_modalContainerBackgroundView release];
	[_vignetteView release];
	[super dealloc];
}

#pragma mark UIViewController

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[UIView beginAnimations:@"rotate" context:self];
	[UIView setAnimationDuration:duration];
	[self layoutViewsWithOrientation:toInterfaceOrientation];
	[UIView commitAnimations];
}

#pragma mark Layout

- (void)layoutViews {
	[self layoutViewsWithOrientation:self.interfaceOrientation];
}


- (void)layoutViewsWithOrientation:(UIInterfaceOrientation)orientation {
	CGSize size;
	
	// Landscape
	if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
		size = CGSizeMake(1024.0, 768.0);
		_vignetteView.frame = CGRectMake(0.0, -128.0, 1024.0, 1024.0);
	}
	
	// Portrait
	else {
		size = CGSizeMake(768.0, 1024.0);
		_vignetteView.frame = CGRectMake(-128.0, 0.0, 1024.0, 1024.0);
	}
	
	_modalContainerBackgroundView.frame = CGRectMake(roundf(size.width - 554.0) / 2.0, (roundf(size.height - 634.0) / 2.0), 554.0, 634.0);
}

#pragma mark Modal

- (void)presentCustomModalViewController:(id<TWModalViewController>)viewController {
	_customModalViewController = [viewController retain];
	
	if (_customModalViewController == nil) {
		return;
	}
	
	_customModalViewController.modalParentViewController = self;
	
	if (_vignetteView == nil) {
		_vignetteView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"images/vignette-ipad.png" bundle:@"TWToolkit.bundle"]];
		_vignetteView.alpha = 0.0;
	}
	
	[self.view addSubview:_vignetteView];
	[_vignetteView fadeIn];
	
	if (_modalContainerBackgroundView == nil) {
		_modalContainerBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"form-background.png"]];
		_modalContainerBackgroundView.autoresizesSubviews = NO;
		_modalContainerBackgroundView.userInteractionEnabled = YES;
	}
	
	[self.view addSubview:_modalContainerBackgroundView];
	
	if (_modalContainerView == nil) {
		_modalContainerView = [[UIView alloc] initWithFrame:CGRectMake(7.0, 7.0, 540.0, 620.0)];
		_modalContainerView.layer.cornerRadius = 5.0;
		_modalContainerView.clipsToBounds = YES;
		[_modalContainerBackgroundView addSubview:_modalContainerView];
	}
	
	UIView *modalView = _customModalViewController.view;
	[_modalContainerView addSubview:modalView];
	modalView.frame = CGRectMake(0.0, 0.0, 540.0, 620.0);
	
	CGSize size;
	if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		size = CGSizeMake(1024.0, 768.0);
	} else {
		size = CGSizeMake(768.0, 1024.0);
	}
	
	_modalContainerBackgroundView.frame = CGRectMake(roundf(size.width - 554.0) / 2.0, (roundf(size.height - 634.0) / 2.0) + size.height, 554.0, 634.0);
	
	[UIView beginAnimations:@"presentModal" context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.5];
	[self layoutViewsWithOrientation:self.interfaceOrientation];
	[UIView commitAnimations];
}


- (void)dismissCustomModalViewController {
	CGSize size;
	if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		size = CGSizeMake(1024.0, 768.0);
	} else {
		size = CGSizeMake(768.0, 1024.0);
	}
	
	[UIView beginAnimations:@"dismissModal" context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.4];
	_modalContainerBackgroundView.frame = CGRectMake(roundf(size.width - 554.0) / 2.0, (roundf(size.height - 634.0) / 2.0) + size.height, 554.0, 634.0);
	[UIView commitAnimations];
	
	[_modalContainerBackgroundView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.5];
	
	[UIView beginAnimations:@"removeVignette" context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDelay:0.2];
	_vignetteView.alpha = 0.0;
	[UIView commitAnimations];
	[_vignetteView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.6];
	
	_customModalViewController = nil;
	
	[_modalContainerView release];
	_modalContainerView = nil;
	
	[_modalContainerBackgroundView release];
	_modalContainerBackgroundView = nil;
}

@end