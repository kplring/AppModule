//
//  AppModule.swift
//
//  Created by zh89 on 2024/8/14.
//

import Foundation
import SwiftUI
import UIKit

@resultBuilder
public struct AnyModuleRegisterBuilder {
    public static func buildBlock(_ components: AnyModuleType.Type...) -> [AnyModuleType.Type] {
        return components
    }
}

// 模块间通信事件接口
public protocol AnyModuleEvent {
    
}

public protocol AnyModuleType: AnyObject {
    //
    // 声明 init 方法，因为我们需要生成实例
    // 用实例，而不用类，更好处理
    // 而且多语言混编工程 iOS 某个版本之后用 runtime 读取所有类出来处理会导致崩溃
    // 因此，不再建议通过 runtime 初始化，显式初始化，更能清晰地表达我们的意图
    //
    init()
    
    //
    // 模块统一的消息处理入口
    //
    // 模块间通信通常有两种方式：
    // 1. 定义一组用于通信的方法
    // 2. 通过模块间通信事件进行处理
    // 我们使用第二种，因为第一种无法枚举所有的场景，意味着最后会有一个用来兜底的 custom 方法，
    // 方法参数可能还会带一个类似 type 这种玩意来作业务区分处理，如果走到这一步这个 custom 方法实际上已经等同于事件分发了。
    // 所以我们干脆一步到位，使用事件分发进行通信！(1、2 全都要是个更坏的习惯...)
    //
    func handleModuleEvent(_ event: AnyModuleEvent) -> Void
    
    func moduleName() -> String
}

public extension AnyModuleType {
    func moduleName() -> String {
        String(reflecting: Self.self)
    }
}

// 入口为 UIKit 模块用这个
public protocol AnyModuleTypeUIKitEntry {
    func entryViewController() -> UIViewController
}

// 入口为 SwiftUI 模块用这个
public protocol AnyModuleTypeEntry {
    func entryView() -> any View
}

// 因为有 init 了，没必要为了强迫症搞个多余的 onLoad, unload 够用了
public protocol AnyModuleTypeLifecycle {
    func onUnload()
}
