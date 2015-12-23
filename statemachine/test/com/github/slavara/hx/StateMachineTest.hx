package com.github.slavara.hx;
import com.github.slavara.hx.StateMachine;
import massive.munit.Assert;

/**
 * @author SlavaRa
 */
class StateMachineTest {

	@Test
	public function create() {
		var smachine = new StateMachine();
		Assert.isNull(smachine.previousState);
		Assert.isNull(smachine.currentState);
	}
	
	@Test
	public function add() {
		var from = "from";
		var to = "to";
		var smachine = new StateMachine()
			.add(from, to);
		Assert.areEqual(from, smachine.currentState);
		smachine.setState(to);
		Assert.areEqual(from, smachine.previousState);
		Assert.areEqual(to, smachine.currentState);
	}
	
	@Test
	public function addTwoWay() {
		var from = "from";
		var to = "to";
		var smachine = new StateMachine()
			.addTwoWay(from, to)
			.setState(to)
			.setState(from);
		Assert.areEqual(from, smachine.currentState);
		Assert.areEqual(to, smachine.previousState);
	}
	
	@Test
	public function addOneToAll() {
		var from = "from";
		var all = ["a", "b"];
		var smachine = new StateMachine()
			.addOneToAll(from, all)
			.setState(all[0]);
		Assert.areEqual(from, smachine.previousState);
		Assert.areEqual(all[0], smachine.currentState);
		smachine = new StateMachine()
			.addOneToAll(from, all)
			.setState(all[1]);
		Assert.areEqual(from, smachine.previousState);
		Assert.areEqual(all[1], smachine.currentState);
	}
	
	@Test
	public function addAllToAll() {
		var a = "a";
		var b = "b";
		var c = "c";
		var smachine = new StateMachine()
			.addAllToAll([a, b, c]);
		Assert.areEqual(a, smachine.currentState);
		smachine.setState(b);
		Assert.areEqual(a, smachine.previousState);
		Assert.areEqual(b, smachine.currentState);
		smachine.setState(c);
		Assert.areEqual(b, smachine.previousState);
		Assert.areEqual(c, smachine.currentState);
		smachine.setState(a);
		Assert.areEqual(c, smachine.previousState);
		Assert.areEqual(a, smachine.currentState);
		smachine.setState(c);
		Assert.areEqual(a, smachine.previousState);
		Assert.areEqual(c, smachine.currentState);
	}
	
	@Test
	public function reset() {
		var smachine = new StateMachine()
			.addAllToAll(["a", "b", "c"])
			.reset();
		Assert.isNull(smachine.previousState);
		Assert.isNull(smachine.currentState);
	}
	
	@Test
	public function fromAtoBviaC() {
		var a = "a";
		var b = "b";
		var c = "c";
		var smachine = new StateMachine()
			.add(a, b, [c])
			.setState(b);
		Assert.areEqual(c, smachine.currentState);
		smachine.release();
		Assert.areEqual(b, smachine.currentState);
	}
	
	@Test
	public function addTwoWayViaC() {
		var a = "a";
		var b = "b";
		var c = "c";
		var smachine = new StateMachine()
			.addTwoWay(a, b, [c])
			.setState(b);
		Assert.areEqual(c, smachine.currentState);
		smachine.release();
		Assert.areEqual(b, smachine.currentState);
		smachine.setState(a);
		Assert.areEqual(c, smachine.currentState);
		smachine.release();
		Assert.areEqual(a, smachine.currentState);
	}
	
	@Test
	public function addOneToAllViaC() {
		var from = "from";
		var all = ["a", "b"];
		var c = "c";
		var smachine = new StateMachine()
			.addOneToAll(from, all, [c])
			.setState(all[0]);
		Assert.areEqual(from, smachine.previousState);
		Assert.areEqual(c, smachine.currentState);
		smachine.release();
		Assert.areEqual(c, smachine.previousState);
		Assert.areEqual(all[0], smachine.currentState);
		smachine.reset()
			.addOneToAll(from, all, [c])
			.setState(all[1]);
		Assert.areEqual(from, smachine.previousState);
		Assert.areEqual(c, smachine.currentState);
		smachine.release();
		Assert.areEqual(c, smachine.previousState);
		Assert.areEqual(all[1], smachine.currentState);
	}
	
	@Test
	public function addAllToAllViaD() {
		var a = "a";
		var b = "b";
		var c = "c";
		var d = "d";
		var smachine = new StateMachine()
			.addAllToAll([a, b, c], [d]);
		Assert.areEqual(a, smachine.currentState);
		smachine.setState(b);
		Assert.areEqual(a, smachine.previousState);
		Assert.areEqual(d, smachine.currentState);
		smachine.release();
		Assert.areEqual(d, smachine.previousState);
		Assert.areEqual(b, smachine.currentState);
		smachine.setState(c);
		Assert.areEqual(b, smachine.previousState);
		Assert.areEqual(d, smachine.currentState);
		smachine.release();
		Assert.areEqual(d, smachine.previousState);
		Assert.areEqual(c, smachine.currentState);
		smachine.setState(a);
		Assert.areEqual(c, smachine.previousState);
		Assert.areEqual(d, smachine.currentState);
		smachine.release();
		Assert.areEqual(d, smachine.previousState);
		Assert.areEqual(a, smachine.currentState);
		smachine.setState(c);
		Assert.areEqual(a, smachine.previousState);
		Assert.areEqual(d, smachine.currentState);
		smachine.release();
		Assert.areEqual(d, smachine.previousState);
		Assert.areEqual(c, smachine.currentState);
	}
	
	@Test
	public function addTransitionListenerFromAToB() {
		var a = "a";
		var b = "b";
		var smachine = new StateMachine()
			.add(a, b)
			.addTransitionListener(a, b, function() Assert.isTrue(true));
		smachine.setState(b);
	}
	
	@Test
	public function removeTransitionListenerFromAToB() {
		var a = "a";
		var b = "b";
		var listener:Void->Void = function() Assert.fail('has transition listener from $a to $b');
		var smachine = new StateMachine()
			.add(a, b)
			.addTransitionListener(a, b, listener)
			.removeTransitionListener(a, b, listener);
		smachine.setState(b);
	}
}