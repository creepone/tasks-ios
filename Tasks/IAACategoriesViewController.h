//
//  IAACategoriesViewController.h
//  Tasks
//
//  Created by Tomas Vana on 3/15/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IAACategoriesViewController;

@protocol IAACategoriesViewControllerDelegate <NSObject>

- (void)categoriesViewController:(IAACategoriesViewController *)notesViewController selectedCategories:(NSSet *)categories;

@end

@interface IAACategoriesViewController : UITableViewController

- (id)initWithSelectedCategories:(NSSet *)categories;

@property (nonatomic, weak) id<IAACategoriesViewControllerDelegate> delegate;

@end
