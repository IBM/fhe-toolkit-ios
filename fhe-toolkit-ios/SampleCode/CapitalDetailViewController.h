/*
* IBM Confidential
*
*
* Copyright IBM Corporation 2020.
*
* The source code for this program is not published or otherwise divested of
* its trade secrets, irrespective of what has been deposited with the US
* Copyright Office.
*/

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CapitalDetailViewController : UIViewController

@property (nonatomic, copy) NSString *queryCountry;
@property (nonatomic, strong) NSTimer *timeTicker;
@property (nonatomic, weak) IBOutlet UILabel *timeGone;
@property (nonatomic, weak) IBOutlet UILabel *logging;
@property (nonatomic, weak) IBOutlet UILabel *countryLabel;
@property (nonatomic, weak) IBOutlet UILabel *capitalResultLabel;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *loadingScreen;

- (void)showTimerActivity;

@end

NS_ASSUME_NONNULL_END
