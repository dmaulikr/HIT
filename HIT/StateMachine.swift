//
//  StateMachine.swift
//  HIT
//
//  Created by Nathan Melehan on 1/23/16.
//  Copyright © 2016 Nathan Melehan. All rights reserved.
//

import Foundation

protocol StateMachineDelegate: class
{
    typealias StateType:StateMachineDataSource
    func didTransitionFrom(from:StateType, to:StateType)
}


protocol StateMachineDataSource
{
    func shouldTransitionFrom(from:Self, to:Self)->Should<Self>
}


enum Should<T>{
    case Continue, Abort, Redirect(T)
}


class StateMachine<P:StateMachineDelegate>{
    private var _state:P.StateType{
        didSet
        {
            delegate.didTransitionFrom(oldValue, to: _state)
        }
    }
    
    unowned let delegate:P
    
    var state:P.StateType{
        get
        {
            return _state
        }
        set
        {
            switch _state.shouldTransitionFrom(_state, to:newValue){
            case .Continue:
                _state = newValue
                
            case .Redirect(let redirectState):
                _state = newValue
                self.state = redirectState
                
            case .Abort:
                break;
            }
        }
    }
    
    init(initialState:P.StateType, delegate:P){
        _state = initialState //set the primitive to avoid calling the delegate.
        self.delegate = delegate
    }
}