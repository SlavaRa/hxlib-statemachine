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
		var all = [a, b, c];
		var smachine = new StateMachine()
			.addAllToAll(all);
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
}