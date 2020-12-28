import Foundation

public protocol Registry {
    func register<T>(_ type: T.Type, closure: @escaping (Resolver) -> T)
}

public protocol Resolver {
    func resolve<T>(_ type: T.Type) -> T
}

public protocol Assembly {
    func assemble(_ registry: Registry)
}

public protocol Container: Registry, Resolver {}

public final class DefaultContainer: Container {
    private let parent: Container?
    private var factories: [ObjectIdentifier: ReferenceResolver] = [:]

    public init(parent: Container? = nil) {
        self.parent = parent
    }

    // MARK: - Registry

    public func register<T>(_ type: T.Type, closure: @escaping (Resolver) -> T) {
        let id = identifier(type)
        factories[id] = SingletonReferenceResolver(factory: closure)
    }

    // MARK: - Resolver

    public func resolve<T>(_ type: T.Type) -> T {
        guard let instance = resolveIfPossible(type) else {
            fatalError("Cannot resolve \(type)")
        }
        return instance
    }

    // MARK: - Private

    private func resolveIfPossible<T>(_ type: T.Type) -> T? {
        let id = identifier(type)
        if let factory = factories[id] {
            return factory.resolve(with: self) as? T
        }
        if let parent = parent {
            return parent.resolve(type)
        }
        return nil
    }

    private func identifier<T>(_ type: T.Type) -> ObjectIdentifier {
        return ObjectIdentifier(type)
    }
}

public final class Assembler {
    private let _container: Container

    public init(container: Container) {
        _container = container
    }

    public func assemble(_ assemblies: [Assembly]) -> Assembler {
        assemblies.forEach {
            $0.assemble(_container)
        }
        return self
    }

    public func container() -> Container {
        return _container
    }
}

private protocol ReferenceResolver {
    func resolve(with resolver: Resolver) -> Any
}

private final class SingletonReferenceResolver: ReferenceResolver {
    private var singleInstance: Any?

    private let factory: (Resolver) -> Any

    init(factory: @escaping (Resolver) -> Any) {
        self.factory = factory
    }

    func resolve(with resolver: Resolver) -> Any {
        if let singleInstance = singleInstance {
            return singleInstance
        }
        let newSingleInstance = factory(resolver)
        singleInstance = newSingleInstance
        return newSingleInstance
    }
}
