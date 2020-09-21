//
//  ESBluetoothCentralManager.h
//  ESBluetoothManager
//
//  Created by codeLocker on 2017/8/7.
//  Copyright © 2017年 codeLocker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "ESPeripheral.h"

@class ESBluetoothCentralManager;
@protocol ESBluetoothCentralManagerDelegate <NSObject>
@optional
/**
 监听蓝牙的硬件状态

 @param manager ESBluetoothCentralManager
 @param central 中心设备
 @param state 蓝牙硬件状态
 */
- (void)bluetoothCentralManager:(ESBluetoothCentralManager *)manager didUpdate:(CBCentralManager *)central state:(CBManagerState)state;

/**
 扫描外围设备

 @param manager ESBluetoothCentralManager
 @param peripheral 外围设备
 */
- (void)bluetoothCentralManager:(ESBluetoothCentralManager *)manager didDiscoverPeripheral:(ESPeripheral *)peripheral;

/**
 连接外围设备成功

 @param manager ESBluetoothCentralManager
 @param peripheral 外围设备
 */
- (void)bluetoothCentralManager:(ESBluetoothCentralManager *)manager didConnectPeripheral:(CBPeripheral *)peripheral;

/**
 连接外围设备失败

 @param manager ESBluetoothCentralManager
 @param peripheral 外围设备
 @param error 错误
 */
- (void)bluetoothCentralManager:(ESBluetoothCentralManager *)manager didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;

/**
 断开外围设备连接

 @param manager ESBluetoothCentralManager
 @param peripheral 外围设备
 @param error 错误
 */
- (void)bluetoothCentralManager:(ESBluetoothCentralManager *)manager didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;

/**
 发现外围设备的服务

 @param manager ESBluetoothCentralManager
 @param peripheral 外围设备
 @param services 搜索到的服务
 @param error 错误
 */
- (void)bluetoothCentralManager:(ESBluetoothCentralManager *)manager didDiscoverPeripheral:(CBPeripheral *)peripheral services:(NSArray<CBService *> *)services error:(NSError *)error;

/**
 发现外围设备服务的特征

 @param manager ESBluetoothCentralManager
 @param peripheral 外围设备
 @param service 服务
 @param characteristics 特征
 @param error 错误
 */
- (void)bluetoothCentralManager:(ESBluetoothCentralManager *)manager didDiscoverPeripheral:(CBPeripheral *)peripheral service:(CBService *)service characteristics:(NSArray<CBCharacteristic *> *)characteristics error:(NSError *)error;

//************
- (void)bluetoothCentralManager:(ESBluetoothCentralManager *)manager didDiscoverPeripheral:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic error:(NSError *)error;

/**
 监听特征状态变化

 @param manager ESBluetoothCentralManager
 @param peripheral 外围设备
 @param characteristic 特征
 @param error 错误
 */
- (void)bluetoothCentralManager:(ESBluetoothCentralManager *)manager peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;

/**
 特征值更新

 @param manager ESBluetoothCentralManager
 @param peripheral 外围设备
 @param characteristic 特征
 @param error 错误
 */
- (void)bluetoothCentralManager:(ESBluetoothCentralManager *)manager peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;




- (void)bluetoothCentralManager:(ESBluetoothCentralManager *)manager peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error;

/**
 向特征值写数据结果

 @param manager ESBluetoothCentralManager
 @param peripheral 外围设备
 @param characteristic 特征
 @param error 错误
 */
- (void)bluetoothCentralManager:(ESBluetoothCentralManager *)manager peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;
@end

@interface ESBluetoothCentralManager : NSObject
/** 外围设备 */
@property (nonatomic, strong) CBPeripheral *peripheral;
/** 手机蓝牙的状态 */
@property (nonatomic, assign) CBManagerState state;
@property (nonatomic, weak) id<ESBluetoothCentralManagerDelegate> delegate;

+ (ESBluetoothCentralManager *)manager;

/**
 扫描周围设备
 
 @param services nil:搜索所有设备 array:搜索指定设备
 */
- (void)scanPeripheralsWithServices:(NSArray <CBUUID *>*)services;

/**
 停止扫描
 */
- (void)stopScan;

/**
 连接外围设备

 @param peripheral 外围设备
 @param options 配置
 */
- (void)connectPeripheral:(CBPeripheral *)peripheral options:(NSDictionary *)options;

/**
 断开与外设的连接
 
 @param peripheral 外围设备
 */
- (void)cancelConnect:(CBPeripheral *)peripheral;

/**
 搜索周围设备的服务

 @param peripheral 外围设备
 @param services 指定搜索服务 nil:搜索所有服务 array:搜索指定服务
 */
- (void)discoverPeripheral:(CBPeripheral *)peripheral services:(NSArray <CBUUID *>*)services;

/**
 搜索外围设备服务的特征
 
 @param peripheral 外围设备
 @param characteristics nil:搜索所有特征 array:搜索指定特征
 @param service 搜索的服务
 */
- (void)discoverPeripheral:(CBPeripheral *)peripheral characteristics:(NSArray *)characteristics forService:(CBService *)service;

- (void)discoverPeripheral:(CBPeripheral *)peripheral descriptorsForCharacteristic:(CBCharacteristic *)characteristic;

/**
 监听外围设备特征值

 @param peripheral 外围设备
 @param characteristic 特征值
 */
- (void)notifyPeripheral:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic;

/**
 取消监听外围设备特征值
 
 @param peripheral 外围设备
 @param characteristic 特征值
 */
- (void)cancelNotifyPeripheral:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic;

/**
 读取特征值

 @param characteristic 特征
 @param peripheral 外围设备
 */
- (void)readCharacteristicValue:(CBCharacteristic *)characteristic forPeripheral:(CBPeripheral *)peripheral;

/**
 向特征写数据

 @param data 数据
 @param peripheral 外围设备
 @param characteristic 特征值
 @param type 类型
 */
- (void)writeValue:(NSData *)data toPeripheral:(CBPeripheral *)peripheral forCharacteristic:(CBCharacteristic *)characteristic type:(CBCharacteristicWriteType)type;
@end
