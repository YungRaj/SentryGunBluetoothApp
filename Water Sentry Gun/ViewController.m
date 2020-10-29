//
//  ViewController.m
//  Water Sentry Gun
//
//  Created by Ilhan Raja on 10/10/20.
//

#import "ViewController.h"
#include "SentryGun.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *connectButton;

@end

@implementation ViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    if(!self.centralManager)
        self.centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    
}
-(IBAction)connectButtonPressed:(id)sender
{
    NSString *settingsUrl= @"App-Prefs:root=Bluetooth";
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {

            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:settingsUrl] options:@{} completionHandler:^(BOOL success) {
                NSLog(@"Bluetooth URL opened");
            }];
    }
}
- (IBAction)leftButtonPressed:(UIButton*)sender
{
    NSString *command = [sender.currentTitle lowercaseString];
    
    [self sendGunCommand:command];
}

- (IBAction)rightButtonPressed:(UIButton*)sender
{
    NSString *command = [sender.currentTitle lowercaseString];
    
    [self sendGunCommand:command];
}

- (IBAction)shootButtonPressed:(UIButton*)sender
{
    NSString *command = [sender.currentTitle lowercaseString];
    
    [self sendGunCommand:command];
}

-(void)sendGunCommand:(NSString*)cmd
{
    const char *utf8 = [cmd UTF8String];
    NSData *value = [NSData dataWithBytes:utf8 length:strlen(utf8)];
    
    [self.rpi4Peripheral writeValue:value forCharacteristic:self.gun_characteristic type:CBCharacteristicWriteWithResponse];
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
    
    [self.centralManager stopScan];
    self.rpi4Peripheral = peripheral;
    peripheral.delegate = self;
    
    [self.centralManager connectPeripheral:peripheral options:options];
    
    NSLog(@"Discovered RPI4!");
}

-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if([central state] == CBManagerStatePoweredOff)
    {
    NSLog(@"Core Bluetooth BLE hardware powered off");
    }
    else if([central state] == CBManagerStatePoweredOn){
        NSLog(@"Core Bluetooth BLE hardware powered on and ready");
        NSArray *services = @[[CBUUID UUIDWithString:RPI4_GUN_SERVICE_UUID]];
        [self.centralManager scanForPeripheralsWithServices:services options:nil];
    }
    else if([central state] == CBManagerStateUnauthorized){
        NSLog(@"Core Bluetooth BLE state is unauthorized");
    }
    else if ([central state] == CBManagerStateUnknown){
        NSLog(@"Core Bluetooth BLE state is unknown");
    }
    else if ([central state] == CBManagerStateUnsupported){
        NSLog(@"Core Bluetooth BLE state is unsupported");
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    for(CBService *service in peripheral.services){
        NSLog(@"Discovered Service: %@", service.UUID);
        
        if([service.UUID isEqual:[CBUUID UUIDWithString:RPI4_GUN_SERVICE_UUID]])
        {
            self.gun_service = service;
            NSLog(@"Discovered RPI4 service");
            
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:RPI4_GUN_CHRC_UUID]] forService:service];
        }
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
   // if([service.UUID isEqual:[CBUUID UUIDWithString:RPI4_GUN_SERVICE_UUID]]){
        for(CBCharacteristic *characteristic in service.characteristics) {
            NSLog(@"Discovered characteristic with UUID %@", [characteristic.UUID UUIDString]);
            if([characteristic.UUID isEqual:[CBUUID UUIDWithString:RPI4_GUN_CHRC_UUID]])
            {
                self.gun_characteristic = characteristic;
                NSLog(@"Discovered RPI4 characteristic");
            }
        }
   // }
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"Peripheral State Changed");
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:RPI4_GUN_CHRC_UUID]])
    {
        NSLog(@"Successfully send command to RPI4");
    }
}


@end
