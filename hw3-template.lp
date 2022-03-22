
%*
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% KRR 2022, HOMEWORK ASSIGNMENT 3 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Name:             Irene Papadopoulou
Student number:   13869337

Name:             Luuk Verheijen
Student number:   11331704

*%

%*
INPUT REPRESENTATION:
- Represent the input of the problem (the map, the trucks, etc.)
*%

truck(1..3).

% load_capacity(Truck,Capacity)
load_capacity(1,1).
load_capacity(2,2).
load_capacity(3,3).

#const battery_capacity=10. % same for all trucks

% Represent the nodes and edges of the map using node/1 and edge/2.
% Nodes are counted from left to right, bottom to top
#const node_n=13.
node(1..node_n).
edge(1,2  ; 2,3   ; 3,7  ; 1,4  ; 4,5  ; 5,6   ; 6,7 ; 7,11 ; 4,8  ; 8,9 ;
	 9,10 ; 10,11 ; 8,12 ; 9,12 ; 9,13 ; 13,10 ; 4,9 ; 5,9  ; 5,10 ; 6,10).

% Edges are undirected, so include their reverse
edge(X,Y) :- edge(Y,X).

% Representing node types in the road map
parking(1;2;3).
warehouse(7).
charger(12;13).
delivery(8;11).

% Representing ranges for state attributes
supply_(0..5).
demand_(0..2).
load_(0..3).
battery_(0..10).
dist_(0..node_n). % use number of nodes as upper bound for distance between two nodes

%*
TIME STEPS:
- Represent the different time steps (up to some upper bound)
*%

#const t=25. % This is an upper bound on the number of time steps needed
possible_time(1..t).
{ time(T) : possible_time(T) }.										% Create all subsets of time
:- not time(1).														% Make sure the first timestep is there
:- possible_time(T), possible_time(T+1), time(T+1), not time(T).	% Make sure timesteps are consecutive
last_timestep(M) :- time(M), not time(T) : possible_time(T), T > M. % Get the last timestep of the subset

%*
ACTIONS:
- Represent the possible actions that each truck can take
*%

action(wait).      				% trucks can wait
action(move(I,J)) :- edge(I,J). % trucks can move to connected nodes
action(load).      				% trucks can load
action(unload).    				% trucks can unload
action(charge).    				% trucks can charge

%*
GENERATE A SEQUENCE OF ACTIONS:
- Generate a sequence of actions (for each truck)
*%

% Perform exactly one action at each time step per truck
1 { do(Truck,A,T) : action(A) } 1 :- time(T), T < M, last_timestep(M), truck(Truck).

%*
INITIAL STATE:
- Encode the initial state
*%

% state(T,truck_load(Truck,Load))
state(1,truck_load(1,0)).	% truck 1 at timestep 1 has load 0
state(1,truck_load(2,0)).	% truck 2 at timestep 1 has load 0
state(1,truck_load(3,0)).	% truck 3 at timestep 1 has load 0

% state(T,supply(Supply))		
state(1,supply(5)).			% at timestep 1 the supply is 5

% state(T,demand(Node,Demand))
state(1,demand(8,2)).		% delivery node 8, at timestep 1 the demand is 2
state(1,demand(11,2)). 		% delivery node 11, at timestep 1 the demand is 2

% state(T,battery(Truck,Battery))
state(1,battery(1,6)). 		% truck 1 at timestep 1 has battery 6
state(1,battery(2,7)).		% truck 2 at timestep 1 has battery 7
state(1,battery(3,10)).		% truck 3 at timestep 1 has battery 10

% state(T,at(Truck,Node))		
state(1,at(1,1)). 			% truck 1 at timestep 1 is at node 1
state(1,at(2,2)). 			% truck 2 at timestep 1 is at node 2
state(1,at(3,3)).			% truck 3 at timestep 1 is at node 3

%*
SUBSEQUENT STATES OF THE WORLD:
- Encode the subsequent states, based on the actions taken

Explanation (max 100 words):
We create fluents which represent the five state attributes we have. 
For each of the state attributes we create one make_true and one make_false predicate
to update the subsequent state accordingly.
*%

% We create fluents based on the valid range of each state attribute
fluent(truck_load(Truck,L)) :- truck(Truck), load_(L).
fluent(supply(S)) 			:- supply_(S).
fluent(demand(Node,D)) 		:- delivery(Node), demand_(D).
fluent(battery(Truck,B)) 	:- truck(Truck), battery_(B).
fluent(at(Truck,Node)) 		:- truck(Truck), node(Node).

% If loading truck then increase load and decrease supply
make_true(T+1,truck_load(Truck,L+1)):- do(Truck,load,T), state(T,truck_load(Truck,L)).
make_false(T+1,truck_load(Truck,L))	:- do(Truck,load,T), state(T,truck_load(Truck,L)).
make_true(T+1,supply(S-1))          :- do(Truck,load,T), state(T,supply(S)).
make_false(T+1,supply(S))           :- do(Truck,load,T), state(T,supply(S)).

% If unloading truck then decrease load and decrease demand
make_true(T+1,truck_load(Truck,L-1)):- do(Truck,unload,T), state(T,truck_load(Truck,L)).
make_false(T+1,truck_load(Truck,L)) :- do(Truck,unload,T), state(T,truck_load(Truck,L)).
make_true(T+1,demand(Node,D-1))  	:- do(Truck,unload,T), state(T,demand(Node,D)), state(T,at(Truck,Node)).
make_false(T+1,demand(Node,D))  	:- do(Truck,unload,T), state(T,demand(Node,D)), state(T,at(Truck,Node)).

% If charging truck then increase battery
make_true(T+1,battery(Truck,B+1))  	:- do(Truck,charge,T), state(T,battery(Truck,B)).
make_false(T+1,battery(Truck,B))  	:- do(Truck,charge,T), state(T,battery(Truck,B)).

% If moving truck then decrease battery and move truck
make_true(T+1,battery(Truck,B-1))  	:- do(Truck,move(I,J),T), state(T,battery(Truck,B)).
make_false(T+1,battery(Truck,B))  	:- do(Truck,move(I,J),T), state(T,battery(Truck,B)).
make_true(T+1,at(Truck,J))        	:- do(Truck,move(I,J),T).
make_false(T+1,at(Truck,I))        	:- do(Truck,move(I,J),T).

% Fluents stay true, unless explicitly made false
state(T,Statement) :- time(T),
    fluent(Statement), state(T-1,Statement), not make_false(T,Statement).
% Fluents that are explicitly made true, become true
state(T,Statement) :- time(T),
    fluent(Statement), make_true(T,Statement).

%*
RESTRICTIONS ON THE ACTIONS:
- Restrict the actions taken by the trucks, based on the state of the world
*%

% truck loading
:- do(Truck,load,T), state(T,at(Truck,Node)), not warehouse(Node).						% Can't load if it's not at a warehouse
:- do(Truck,load,T), state(T,truck_load(Truck,L)), load_capacity(Truck,Cap), L >= Cap.	% Can't load if it's at capacity
:- do(Truck,load,T), state(T,supply(S)), S < 1.											% Can't load if there's no supply

% truck unloading
:- do(Truck,unload,T), state(T,at(Truck,Node)), not delivery(Node).				% Can't unload if it's not at a delivery location
:- do(Truck,unload,T), state(T,truck_load(Truck,L)), L < 1.						% Can't unload if it's not loaded
:- do(Truck,unload,T), state(T,demand(Node,D)), state(T,at(Truck,Node)), D < 1.	% Can't unload if there's no demand

% charging
:- do(Truck,charge,T), state(T,at(Truck,Node)), not charger(Node).		 % Can't charge if it's not at a charging station
:- do(Truck,charge,T), state(T,battery(Truck,B)), B >= battery_capacity. % Can't charge if battery is at capacity

% moving
:- do(Truck,move(I,J),T), state(T,at(Truck,Node)), Node!=I. 		% Can't move from node where truck is not at
:- do(Truck,move(I,J),T), state(T,battery(Truck,B)), B < 1. 		% Can't move with dead battery
:- do(Truck1,move(I,J),T), state(T+1,at(Truck2,J)), Truck1!=Truck2. % Can't move to node where another truck will be
:- do(Truck1,move(I1,J1),T), do(Truck2,move(I2,J2),T), Truck1!=Truck2, I1=J2, I2=J1. % Can't pass another truck on a piece of road
:- state(T,at(Truck1,Node)), state(T,at(Truck2,Node)), Truck1 != Truck2.			 % Two trucks can't be at the same node

%*
GOAL CONDITIONS:
- Constraints that express that the goal must be reached
*%

% Get shortest distance from node A to node B
shortest_path(A,A,0) :- node(A).
shortest_path(A,B,1) :- edge(A,B).
shortest_path(A,B,D1+1) :- dist_(D1+1), shortest_path(A,Mid,D1), edge(Mid,B), not shortest_path(A,B,D2): dist_(D2), D1 > D2.

% Get shortest distance from any node to the closest charger
shortest_to_charge(Node,Dist) :- Dist=#min { D : shortest_path(Node,Charger,D), charger(Charger) }, node(Node).

% Check sufficient battery to reach a charger
can_charge(Truck,T) :- state(T,battery(Truck,B)), state(T,at(Truck,Node)), shortest_to_charge(Node,Dist), B>=Dist.

% Make sure that all trucks can charge at any timestep
% This is only necessary for the goal state but it's always useful
:- not can_charge(Truck,T), truck(Truck), time(T).

% Check if all trucks are parked
parked(Truck,T) :- state(T,at(Truck,Node)), parking(Node).
all_parked(T) :- parked(Truck,T) : truck(Truck); time(T).

% Check if goal is reached at timestep T
goal_reached(T) :- time(T),
	state(T,demand(Loc,0)) : delivery(Loc); 	% There is no demand at any delivery locations	
	all_parked(T),								% All trucks are parked
	state(T,truck_load(Truck,0)) : truck(Truck).% All trucks have no packages aboard

% Make sure the goal is reached at the last timestep
:- not goal_reached(T), last_timestep(T).

% Make sure there are no more timesteps after the goal is reached
:- last_timestep(M), goal_reached(T), M > T.

%*
OPTIMIZATION:
- Express an optimization statement to find a solution within the smallest
  number of time steps
*%

% Find optimal solution by minimizing the last timestep
#minimize { T : last_timestep(T) }.
#show.

%*
PRETTY PRINTING
*%
#script (python)

import clingo
from collections import defaultdict

def ext(obj, length=11):
	"""Extend whitespace for printing"""
	return ' '*(length-len(str(obj)))

def on_model(model):
	truck_ids = [1,2,3]
	actions = dict()
	time_steps = set()

	truck_states = defaultdict(dict)
	demand = defaultdict(dict)
	supply = dict()

	goal_first_reached = None
	can_charge = dict()

	for atom in model.symbols(atoms=True):
		if atom.name == "can_charge":
			truck = atom.arguments[0].number
			time = atom.arguments[1].number
			can_charge[(time,truck)] = True

		if atom.name == "do":
			truck = atom.arguments[0].number
			action = atom.arguments[1]
			time = atom.arguments[2].number

			if actions.get((time,truck)):
				print("Double assignment")
			actions[(time,truck)] = action

		if atom.name == "state":
			time = atom.arguments[0].number
			time_steps.add(time)
			subatom = atom.arguments[1]
			if subatom.name == "at":
				truck = subatom.arguments[0].number
				node = subatom.arguments[1].number

				if truck_states[(time,truck)].get("at"):
					print("Double assignment")
				truck_states[(time,truck)]["at"] = node

			if subatom.name == "truck_load":
				truck = subatom.arguments[0].number
				load = subatom.arguments[1].number

				if truck_states[(time,truck)].get("load"):
					print("Double assignment")
				truck_states[(time,truck)]["load"] = load

			if subatom.name == "battery":
				truck = subatom.arguments[0].number
				battery = subatom.arguments[1].number

				if truck_states[(time,truck)].get("battery"):
					print("Double assignment")
				truck_states[(time,truck)]["battery"] = battery

			if subatom.name == "supply":
				if supply.get(time):
					print("Double assignment")
				supply[time] = subatom.arguments[0].number

			if subatom.name == "demand":
				node = subatom.arguments[0].number

				if demand[node].get(time):
					print("Double assignment")
				demand[node][time] = subatom.arguments[1].number

	print("Pretty printed answer set:")
	time_steps = list(time_steps)
	time_steps.sort()
	print(time_steps)
	for time in time_steps:
		goal_string = ""
		if time == time_steps[-1]:
			goal_string = " GOAL REACHED"
		
		print(f"TIME STEP {time}{goal_string}")
		for truck in truck_ids:
			action = ''
			if actions.get((time,truck)):
				action =  actions[(time,truck)]
			node =    truck_states[(time,truck)]['at']
			battery = truck_states[(time,truck)]['battery']
			load =    truck_states[(time,truck)]['load']
			print(f"  Tr{truck} N{node}{ext(node,2)} {action}{ext(action)} B={battery}{ext(battery,2)} L={load} Can-Charge:{can_charge.get((time,truck))}")
		print(f"  Supply:   {supply[time]}")
		print(f"  Demand8:  {demand[8][time]}")
		print(f"  Demand11: {demand[11][time]}")
		print()

def main(prg):
	prg.ground([("base", [])])
	prg.solve(on_model=on_model)

#end.

%*
THE END
*%
