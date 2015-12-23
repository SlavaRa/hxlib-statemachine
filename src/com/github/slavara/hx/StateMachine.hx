package com.github.slavara.hx;
using Lambda;

class StateMachine {

	public function new() reset();
	
	public var currentState(default, null):String;
	public var previousState(default, null):String;
	
	var _transitions:Map<String, Map<String, StateTransition>>;
	var _queuedState:String;
	var _statesQueue:Array<String>;
	var _transitionListeners:Map<String, Map<String, Array<Void -> Void>>>;
	var _inTransition:Bool;
	var _buildFrom:String;
	var _buildVia:Array<String>;
	
	public function reset():StateMachine {
		currentState = null;
		previousState = null;
		_transitions = new Map();
		_queuedState = null;
		_statesQueue = null;
		_transitionListeners = new Map();
		_inTransition = false;
		_buildFrom = null;
		_buildVia = null;
		return this;
	}
	
	public function from(state:String):StateMachine {
		_buildFrom = state;
		return this;
	}
	public function via(states:Array<String>):StateMachine {
		_buildVia = states;
		return this;
	}
	public function to(state:String):StateMachine {
		return add(_buildFrom, state, _buildVia);
	}
	
	public function add(from:String, to:String, ?via:Array<String>):StateMachine {
		_buildFrom = null;
		_buildVia = null;
		if(!_transitions.exists(from)) _transitions.set(from, new Map());
		if(!_transitions.exists(to)) _transitions.set(to, new Map());
		_transitions.get(from).set(to, new StateTransition(from, to, via));
		return currentState == null ? setState(from) : this;
	}
	
	public function addTwoWay(from:String, to:String, ?via:Array<String>):StateMachine {
		add(from, to, via);
		add(to, from, via);
		return this;
	}
	
	public function addOneToAll(from:String, to:Array<String>, ?via:Array<String>):StateMachine {
		for(toState in to) add(from, toState, via);
		return this;
	}
	
	public function addAllToAll(all:Array<String>, ?via:Array<String>):StateMachine {
		for(from in all) for(to in all) addTwoWay(from, to, via);
		return this;
	}
	
	public function setState(state:String):StateMachine {
		_buildFrom = null;
		_buildVia = null;
		if(currentState == null) {
			currentState = state;
			broadcastStateChange(null, currentState);
		}
		if(state == currentState) return this;
		if(_inTransition) {
			_queuedState = state;
			return this;
		}
		_queuedState = null;
		if(!_transitions.exists(currentState)) return this;
		var transition = _transitions.get(currentState).get(state);
		if(transition == null) return this;
		previousState = currentState;
		if(transition.simple) {
			currentState = transition.to;
			broadcastStateChange(transition.from, transition.to);
		} else {
			_inTransition = true;
			_statesQueue = transition.queue;
			setNextQueuedState();
		}
		return this;
	}
	
	public function release():StateMachine {
		_buildFrom = null;
		_buildVia = null;
		setNextQueuedState();
		return this;
	}
	
	public function addTransitionListener(from:String, to:String, listener:Void -> Void):StateMachine {
		if(!_transitionListeners.exists(from)) _transitionListeners.set(from, new Map());
		var to2listeners = _transitionListeners.get(from);
		if(!to2listeners.exists(to)) to2listeners.set(to, []);
		var listeners = to2listeners.get(to);
		if(!listeners.has(listener)) listeners.push(listener);
		return this;
	}
	
	public function removeTransitionListener(from:String, to:String, listener:Void -> Void):StateMachine {
		if(!_transitionListeners.exists(from)) return this;
		var to2listeners = _transitionListeners.get(from);
		if(!to2listeners.exists(to)) return this;
		var listerens = to2listeners.get(to);
		listerens.remove(listener);
		if(listerens.empty()) to2listeners.remove(to);
		if(to2listeners.empty()) _transitionListeners.remove(from);
		return this;
	}
	
	@:noCompletion
	@:final
	function setNextQueuedState() {
		previousState = currentState;
		currentState = _statesQueue[0];
		_statesQueue.remove(currentState);
		broadcastStateChange(previousState, currentState);
		_inTransition = !_statesQueue.empty();
		var state2transition = _transitions.get(currentState);
		if(state2transition != null && _inTransition) {
			if(_queuedState != null) {
				var transition = state2transition.get(_queuedState);
				if(transition != null) {
					_inTransition = false;
					_statesQueue = null;
					setState(_queuedState);
				}
			} else if(_inTransition) setNextQueuedState();
		}
	}
	
	@:noCompletion
	@:final
	function broadcastStateChange(from:String, to:String) {
		//onChange.dispatch();
		if(_transitionListeners.exists(from)) {
			var listeners = _transitionListeners.get(from);
			if(listeners.exists(to)) for(it in listeners.get(to)) it();
		}
	}
}

private class StateTransition {
	
	public function new(from:String, to:String, ?via:Array<String>) {
		this.from = from;
		this.to = to;
		if(via != null) {
			_queue = via.copy();
			_queue.push(to);
		}
	}
	
	public var from(default, null):String;
	public var to(default, null):String;
	
	var _queue:Array<String>;
	public var queue(get, null):Array<String>;
	inline function get_queue():Array<String> return _queue != null ? _queue.copy() : [];
	
	public var simple(get, null):Bool;
	inline function get_simple():Bool return _queue == null;
}