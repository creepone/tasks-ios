//
//  IAANotesViewController.h
//  Tasks
//
//  Created by Tomas Vana on 3/15/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IAANotesViewController;

@protocol IAANotesViewControllerDelegate <NSObject>

- (void)notesViewController:(IAANotesViewController *)notesViewController editedNotes:(NSString *)notes;

@end

@interface IAANotesViewController : UIViewController

- (id)initWithNotes:(NSString *)notes;

@property (nonatomic, weak) id<IAANotesViewControllerDelegate> delegate;

@end
