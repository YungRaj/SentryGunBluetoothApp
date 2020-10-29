//
//  ViewController.h
//  Water Sentry Gun
//
//  Created by Ilhan Raja on 10/10/20.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "SentryGun.h"

@interface ViewController : UIViewController <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *rpi4Peripheral;
@property (nonatomic, strong) CBService *gun_service;
@property (nonatomic, strong) CBCharacteristic *gun_characteristic;

@end

