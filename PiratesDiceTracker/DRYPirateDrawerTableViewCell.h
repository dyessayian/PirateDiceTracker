//
//  DRYPirateDrawerTableViewCell.h
//  PiratesDiceTracker
//
//  Created by Daniel Yessayian on 10/24/15.
//  Copyright © 2015 Daniel Yessayian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DRYPirateDrawerTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *cellDiceLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellProbabilityLabel;

@end
