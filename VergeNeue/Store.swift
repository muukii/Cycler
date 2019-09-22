//
//  Store.swift
//  VergeNeue
//
//  Created by muukii on 2019/09/18.
//  Copyright © 2019 muukii. All rights reserved.
//

import Foundation

open class Store<Reducer: ModularReducerType> {
    
  public typealias State = Reducer.TargetState
  
  public final var state: State {
    storage.value
  }
  
  let storage: Storage<State>
  
  public let reducer: Reducer
  
  private let lock = NSLock()
  
  private var _deinit: () -> Void = {}
  
  private let logger: StoreLogger?
  
  @_Atomic private var adapters: [AdapterBase<Reducer>] = []
      
  public init(
    reducer: Reducer,
    logger: StoreLogger? = nil
  ) {
    self.storage = .init(reducer.makeInitialState())
    self.reducer = reducer
    self.logger = logger
    
    #if DEBUG
    print("Init", self)
    #endif
  }
  
  public convenience init<ParentReducer: ReducerType>(
    reducer: Reducer,
    registerParent parentStore: Store<ParentReducer>,
    logger: StoreLogger? = nil
  )
    where Reducer.ParentReducer == ParentReducer
  {
            
    self.init(reducer: reducer, logger: logger)
    
    let parentSubscripton = parentStore.storage.add { [weak self] (state) in
      self?.notify(newParentState: state)
    }
    
    notifyCurrent: do {
      notify(newParentState: parentStore.storage.value)      
    }
    
    self._deinit = { [weak storage = parentStore.storage] in
      storage?.remove(subscriber: parentSubscripton)
    }
    
  }
  
  deinit {
    #if DEBUG
    print("Deinit", self)
    #endif
    _deinit()
  }
  
  // MARK: - Functions
  
  @discardableResult
  public func addAdapter(_ adapter: AdapterBase<Reducer>) -> Self {
    adapters.append(adapter)
    adapter.store = self
    return self
  }
  
  @discardableResult
  public func removeAdapter(_ adapter: AdapterBase<Reducer>) -> Self {
    adapters.removeAll { $0 === adapter }
    return self
  }
  
  private func notify(newParentState: Reducer.ParentReducer.TargetState) {
    reducer.parentChanged(newState: newParentState)
  }

  @discardableResult
  public final func dispatch<ReturnType>(_ makeAction: (Reducer) -> Reducer.Action<ReturnType>) -> ReturnType {
    let context = StoreDispatchContext<Reducer>.init(store: self)
    let action = makeAction(reducer)
    let result = action.action(context)
    logger?.didDispatch(store: self, state: state, action: action.metadata)
    return result
  }
  
  public final func commit(_ makeMutation: (Reducer) -> Reducer.Mutation) {
            
    let mutation = makeMutation(reducer)
    
    logger?.willCommit(store: self, state: state, mutation: mutation.metadata)
    defer {
      logger?.didCommit(store: self, state: state, mutation: mutation.metadata)
    }
    
    storage.update { (state) in
      mutation.mutate(&state)
    }
  }
  
  public final func makeScoped<ScopedReducer: ScopedReducerType>(
    reducer: ScopedReducer
  ) -> ScopedStore<ScopedReducer> where ScopedReducer.SourceReducer == Reducer {
        
    let scopedStore = ScopedStore<ScopedReducer>(
      sourceStore: self,
      scopeSelector: reducer.scopeKeyPath,
      reducer: reducer
    )
    
    return scopedStore
  }
  
}
