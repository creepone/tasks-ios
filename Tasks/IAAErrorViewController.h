//
//  IAAErrorViewController.h
//  Tasks
//
//  Created by Tomas Vana on 3/2/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IAAErrorViewController : UIViewController

@property (nonatomic, strong) IBOutlet UITextView *textViewDetails;
@property (nonatomic, copy) dispatch_block_t callbackDismiss;

- (id)initWithError:(NSError *)error;

- (IBAction)tappedDismiss:(id)sender;

@end
