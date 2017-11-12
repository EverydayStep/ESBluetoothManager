//
//  ESBluetoothCentralManager.m
//  ESBluetoothManager
//
//  Created by codeLocker on 2017/8/7.
//  Copyright © 2017年 codeLocker. All rights reserved.
//

#import "ESBluetoothCentralManager.h"

@interface ESBluetoothCentralManager()<CBCentralManagerDelegate, CBPeripheralDelegate>
@property (nonatomic, strong) CBCentralManager *central;
@end

@implementation ESBluetoothCentralManager
+ (ESBluetoothCentralManager *)manager {
    static ESBluetoothCentralManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ESBluetoothCentralManager alloc] init];
    });
    return manager;
}

- (id)init {
    self = [super init];
    if (self) {
        self.central = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    return self;
}

#pragma mark - Bluetooth_Methods
#pragma mark -  Scan
- (void)scanPeripheralsWithServices:(NSArray <CBUUID *>*)services {
    [self.central scanForPeripheralsWithServices:services options:nil];
}

- (void)stopScan {
    if(self.central.isScanning) {
        [self.central stopScan];
    }
}

#pragma mark - Connect
- (void)connectPeripheral:(CBPeripheral *)peripheral options:(NSDictionary *)options {
    if (!peripheral) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(bluetoothCentralManager:didFailToConnectPeripheral:error:)]) {
            NSError *error = [NSError errorWithDomain:@"周围设备不能为nil" code:-100 userInfo:nil];
            [self.delegate bluetoothCentralManager:self didFailToConnectPeripheral:peripheral error:error];
        }
        return;
    }
    self.peripheral = peripheral;
    [self.central connectPeripheral:self.peripheral options:options];
}

- (void)cancelConnect:(CBPeripheral *)peripheral {
    [self.central cancelPeripheralConnection:peripheral];
}

#pragma mark - Discover
- (void)discoverPeripheral:(CBPeripheral *)peripheral services:(NSArray <CBUUID *>*)services {
    if (!peripheral) {
        NSError *error = [NSError errorWithDomain:@"周围设备不能为nil" code:-100 userInfo:nil];
        if (!self.delegate && [self.delegate respondsToSelector:@selector(bluetoothCentralManager:didDiscoverPeripheral:services:error:)]) {
            [self.delegate bluetoothCentralManager:self didDiscoverPeripheral:peripheral services:nil error:error];
        }
        return;
    }
    peripheral.delegate = self;
    [peripheral discoverServices:services];
}

- (void)discoverPeripheral:(CBPeripheral *)peripheral characteristics:(NSArray *)characteristics forService:(CBService *)service {
    if (!peripheral) {
        NSError *error = [NSError errorWithDomain:@"周围设备不能为nil" code:-100 userInfo:nil];
        if (self.delegate && [self.delegate respondsToSelector:@selector(bluetoothCentralManager:didDiscoverPeripheral:service:characteristics:error:)]) {
            [self.delegate bluetoothCentralManager:self didDiscoverPeripheral:peripheral service:service characteristics:nil error:error];
        }
        return;
    }
    [peripheral discoverCharacteristics:characteristics forService:service];
}

#pragma mark - Notify
- (void)notifyPeripheral:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic {
    if (!peripheral) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(bluetoothCentralManager:peripheral:didUpdateNotificationStateForCharacteristic:error:)]) {
            NSError *error = [NSError errorWithDomain:@"周围设备不能为nil" code:-100 userInfo:nil];
            [self.delegate bluetoothCentralManager:self peripheral:peripheral didUpdateNotificationStateForCharacteristic:characteristic error:error];
        }
        return;
    }
    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
}

- (void)cancelNotifyPeripheral:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic {
    if (!peripheral) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(bluetoothCentralManager:peripheral:didUpdateNotificationStateForCharacteristic:error:)]) {
            NSError *error = [NSError errorWithDomain:@"周围设备不能为nil" code:-100 userInfo:nil];
            [self.delegate bluetoothCentralManager:self peripheral:peripheral didUpdateNotificationStateForCharacteristic:characteristic error:error];
        }
        return;
    }
    [peripheral setNotifyValue:NO forCharacteristic:characteristic];
}

#pragma mark - Value
- (void)readCharacteristicValue:(CBCharacteristic *)characteristic forPeripheral:(CBPeripheral *)peripheral {
    if (!characteristic || !peripheral) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(bluetoothCentralManager:peripheral:didUpdateValueForCharacteristic:error:)]) {
            NSError *error = [NSError errorWithDomain:@"周围设备不能为nil" code:-100 userInfo:nil];
            [self.delegate bluetoothCentralManager:self peripheral:peripheral didUpdateValueForCharacteristic:characteristic error:error];
        }
        return;
    }
    [peripheral readValueForCharacteristic:characteristic];
}

- (void)writeValue:(NSData *)data toPeripheral:(CBPeripheral *)peripheral forCharacteristic:(CBCharacteristic *)characteristic type:(CBCharacteristicWriteType)type {
    if (!peripheral || !characteristic) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(bluetoothCentralManager:peripheral:didWriteValueForCharacteristic:error:)]) {
            NSError *error = [NSError errorWithDomain:@"周围设备不能为nil" code:-100 userInfo:nil];
            [self.delegate bluetoothCentralManager:self peripheral:peripheral didWriteValueForCharacteristic:characteristic error:error];
        }
        return;
    }
    [peripheral writeValue:data forCharacteristic:characteristic type:type];
}

#pragma mark - CBCentralManagerDelegate
//蓝牙硬件的状态
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (self.delegate && [self.delegate respondsToSelector:@selector(bluetoothCentralManager:didUpdate:state:)]) {
        [self.delegate bluetoothCentralManager:self didUpdate:central state:central.state];
    }
}
//发现外围设备
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    ESPeripheral *es_peripheral = [[ESPeripheral alloc] init];
    es_peripheral.peripheral = peripheral;
    es_peripheral.advertisementData = advertisementData;
    es_peripheral.RSSI = RSSI;
    if (self.delegate && [self.delegate respondsToSelector:@selector(bluetoothCentralManager:didDiscoverPeripheral:)]) {
        [self.delegate bluetoothCentralManager:self didDiscoverPeripheral:es_peripheral];
    }
}
//连接外围设备成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    if (self.delegate && [self.delegate respondsToSelector:@selector(bluetoothCentralManager:didConnectPeripheral:)]) {
        [self.delegate bluetoothCentralManager:self didConnectPeripheral:peripheral];
    }
}
//连接外围设备失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(bluetoothCentralManager:didFailToConnectPeripheral:error:)]) {
        [self.delegate bluetoothCentralManager:self didFailToConnectPeripheral:peripheral error:error];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(bluetoothCentralManager:didDisconnectPeripheral:error:)]) {
        [self.delegate bluetoothCentralManager:self didDisconnectPeripheral:peripheral error:error];
    }
}

#pragma mark - CBPeripheralDelegate
//发现外围设备服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(bluetoothCentralManager:didDiscoverPeripheral:services:error:)]) {
        [self.delegate bluetoothCentralManager:self didDiscoverPeripheral:peripheral services:peripheral.services error:error];
    }
}
//发现外围设备服务特征
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(bluetoothCentralManager:didDiscoverPeripheral:service:characteristics:error:)]) {
        [self.delegate bluetoothCentralManager:self didDiscoverPeripheral:peripheral service:service characteristics:service.characteristics error:error];
    }
}

//特征值监听状态变化
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(bluetoothCentralManager:peripheral:didUpdateNotificationStateForCharacteristic:error:)]) {
        [self.delegate bluetoothCentralManager:self peripheral:peripheral didUpdateNotificationStateForCharacteristic:characteristic error:error];
    }
}

//特征值更新
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(bluetoothCentralManager:peripheral:didUpdateValueForCharacteristic:error:)]) {
        [self.delegate bluetoothCentralManager:self peripheral:peripheral didUpdateValueForCharacteristic:characteristic error:error];
    }
}

//向特征写数据结果
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(bluetoothCentralManager:peripheral:didWriteValueForCharacteristic:error:)]) {
        [self.delegate bluetoothCentralManager:self peripheral:peripheral didWriteValueForCharacteristic:characteristic error:error];
    }
}

#pragma mark - Setter && Getter
- (CBManagerState)state {
    return self.central.state;
}
@end
