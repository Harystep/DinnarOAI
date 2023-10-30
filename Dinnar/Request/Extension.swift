//
//  Extension.swift
//  Dinnar
//
//  Created by Lizheng Pang on 2023/6/24.
//

import Foundation
public struct ExtensionWrapper<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol ExtensionCompatible: AnyObject { }

extension ExtensionCompatible {
    public var kl: ExtensionWrapper<Self> {
        get { return ExtensionWrapper(self) }
        set { }
    }
    
    public static var kl: ExtensionWrapper<Self>.Type {
        get { return ExtensionWrapper.self }
        set { }
    }
}

public protocol ExtensionCompatibleValue {}

extension ExtensionCompatibleValue {
    public var kl: ExtensionWrapper<Self> {
        get { return ExtensionWrapper(self) }
        set { }
    }
    
    public static var kl: ExtensionWrapper<Self>.Type {
        get { return ExtensionWrapper.self }
        set { }
    }
}
