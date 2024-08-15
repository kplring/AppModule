//
//  AppModuleManager.swift
//
//  Created by zh89 on 2024/8/14.
//

import Foundation
import Combine

public class AppModuleManager {
    
    private init() {
        
    }
    
    static let shared = AppModuleManager()
    
    // 还得是 combine 简单暴力...
    private let eventSubject = PassthroughSubject<AnyModuleEvent, Never>()
    private var sharePublisher: AnyPublisher<AnyModuleEvent, Never> {
        eventSubject.share().eraseToAnyPublisher()
    }
    
    private var modInstHolders: [String: ModuleInstanceHolder] = [:]
    
    private var registeredModules: [AnyModuleType.Type] = []
    
    
    public static func sendEvent(_ event: AnyModuleEvent) {
        shared.eventSubject.send(event)
    }
    
    public static func regiter(@AnyModuleRegisterBuilder _ builder: () -> [AnyModuleType.Type]) -> Void {
        shared.registeredModules = builder()
    }
    
    public static func load() {
        shared.registeredModules.forEach { type in
            let key = String(reflecting: type)
            let holder = ModuleInstanceHolder()
            holder.instance = type.init()
            shared.modInstHolders[key] = holder
        }
    }
    
    public static func unload(_ moduleType: AnyModuleType.Type) {
        let key = String(reflecting: moduleType)
        if let holder = shared.modInstHolders[key] {
            if holder.instance is AnyModuleTypeLifecycle {
                (holder.instance as! AnyModuleTypeLifecycle).onUnload()
            }
            holder.instance = nil
            shared.modInstHolders[key] = nil
        }
    }
}

final class ModuleInstanceHolder {
    
    var instance: AnyModuleType?
    var cancellable: AnyCancellable?
    
    func subscribeModuleEvents(_ publisher: AnyPublisher<AnyModuleEvent, Never>) -> Void {
        cancellable = publisher.sink { [weak self] event in
            self?.instance?.handleModuleEvent(event)
        }
    }
}
