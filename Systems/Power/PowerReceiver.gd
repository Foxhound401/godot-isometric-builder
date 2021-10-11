## Component that receives electricity from a PowerSource.
## Add it as a child of a machine that needs electricity to be powered
class_name PowerReceiver
extends Node

## Signal for the entity to react to it for when the receiver gets an amount of
## power each system tick.
## A battery can increase the amount of power stored, or an electirc furnance can 

## begin smelting ore once it receives the power it needs.

signal received_power(amount, delta)

## The required amount of power for the machine to function in units per tick optimally.
## If it receives less than that amount, it may mean the machine does not work or that it slows down.

export var power_required := 	10.0

## The possible directions for power to come _in_ from, if not omnidirectional.
## The FLAGS keyword makes it a multiple-choice answer in the inspector.

export (Types.Direction, FLAGS) var input_direction := 15

## How efficient the machine is at present. For instance, a machine that has no work
## to do has an efficiency of `0` when one that has a job has an efficiency of `1`.
## Affects the final power demand.
var efficiency := 0.0

## Return a float indicating the required power multiplied by the current efficiency.
func get_effective_power() -> float:
	return power_required * efficiency
