%*
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% KRR 2022, HOMEWORK ASSIGNMENT 3 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Name:             ...
Student number:   ...

Name:             ...
Student number:   ...

*%

%*
INPUT REPRESENTATION:
- Represent the input of the problem (the map, the trucks, etc.)

[EXPLAIN YOUR CODE USING SHORT INLINE COMMENTS (SEE EXAMPLE BELOW)]
*%
truck(1..3).

% load_capacity(Truck,Cap)
load_capacity(1,1).
load_capacity(2,2).
load_capacity(3,3).

#const battery_capacity=10.

supply_(0..5).
demand_(0..2).
load_(0..3).
battery_(0..10).

% Represent the nodes and edges of the map using node/1 and edge/2.
node(1..13).
edge(1,2).
edge(2,3).
edge(3,7).
edge(1,4).
edge(4,5).
edge(5,6).
edge(6,7).
edge(7,11).
edge(4,8).
edge(8,9).
edge(9,10).
edge(10,11).
edge(8,12).
edge(9,12).
edge(9,13).
edge(13,10).
edge(4,9).
edge(5,9).
edge(5,10).
edge(6,10).

% Edges are undirected, so include their reverse
edge(X,Y) :- edge(Y,X).

% Representing node types in the road map
parking(1;2;3).
warehouse(7).
charger(12;13).
delivery(8;11).


%*
TIME STEPS:
- Represent the different time steps (up to some upper bound)
*%

#const t=25. % This is an upper bound on the number of time steps needed
time(1..t).

%*
ACTIONS:
- Represent the possible actions that each truck can take
*%
adjacent_node(I,J) :- node(I), node(J), edge(I,J).

action(wait).      % trucks can wait
action(move(I,J)) :- adjacent_node(I,J).  % trucks can move to adjacent nodes
action(load).      % trucks can load from the warehouse
action(unload).    % trucks can unload
action(charge).    % trucks can charge

%*
GENERATE A SEQUENCE OF ACTIONS:
- Generate a sequence of actions (for each truck)
*%
% We perform exactly one action at each time step per truck
1 { do(Truck,A,T) : action(A) } 1 :- time(T), T < t, truck(Truck).

%*
INITIAL STATE:
- Encode the initial state
*%

% supply(T, Supply)
supply(1,5). % at timestep 1 the supply is 5

% demand(Node, T, Demand)
demand(8,1,2). % delivery node 8, at timestep 1 the demand is 2
demand(11,1,2). % delivery node 11, at timestep 1 the demand is 2

% truck_load(Truck, T, Load)
truck_load(1,1,0). % truck 1 at timestep 1 has load 0
truck_load(2,1,0).
truck_load(3,1,0).

% battery(Truck, T, Battery)
battery(1,1,6). % truck 1 at timestep 1 has battery 6
battery(2,1,7).
battery(3,1,10).

% at(Truck, T, Node)
at(1,1,1). % truck 1 at timestep 1 at node 1
at(2,1,2). % truck 2 at timestep 1 at node 2
at(3,1,3).

%*
SUBSEQUENT STATES OF THE WORLD:
- Encode the subsequent states, based on the actions taken

Explanation (max 100 words):
[WRITE YOUR EXPLANATION HERE]
*%

% If loading truck then increase load and decrease supply
truck_load(Truck,T+1,L+1) :- do(Truck,load,T), truck_load(Truck,T,L).
supply(T+1,S-1)           :- do(Truck,load,T), supply(T,S).

% If unloading truck then decrease load and decrease demand
truck_load(Truck,T+1,L-1) :- do(Truck,unload,T), truck_load(Truck,T,L).
demand(Location,T+1,D-1)  :- do(Truck,unload,T), demand(Location,T,D), at(Truck,T,Location).

% If charging truck then increase battery
battery(Truck,T+1,B+1)  :- do(Truck,charge,T), battery(Truck,T,B).

% If moving truck then decrease battery and move truck
battery(Truck,T+1,B-1)  :- do(Truck,move(I,J),T), battery(Truck,T,B).
at(Truck,T+1,J)         :- do(Truck,move(I,J),T).

% fluents
% truck_load(Truck,T+1,L1):- truck_load(Truck,T,L1); not truck_load(Truck,T+1,L2) : |L1-L2|=1, load_(L2).
% supply(T+1,S1)          :- supply(T,S1), not supply(T+1,S2), |S1-S2|=1, supply_(S2).
% demand(Node,T+1,D1) 		:- demand(Node,T,D1), not demand(Node,T+1,D2), |D1-D2|=1, demand_(D2).
% battery(Truck,T+1,B1)  	:- battery(Truck,T,B1), not battery(Truck,T+1,B2), |B1-B2|=1, battery_(B2).
% at(Truck,T+1,Node1)     :- at(Truck,T,Node1); not at(Truck,T+1,Node2) : adjacent_node(Node1,Node2).


%*
RESTRICTIONS ON THE ACTIONS:
- Restrict the actions taken by the trucks, based on the state of the world

Explanation (max 100 words):
[WRITE YOUR EXPLANATION HERE]
*%

% truck loading
:- do(Truck,load,T), at(Truck,T,Node), not warehouse(Node).
:- do(Truck,load,T), truck_load(Truck,T,L), load_capacity(Truck,Cap), L >= Cap.
:- do(Truck,load,T), supply(T,S), S < 1.

% truck unloading
:- do(Truck,unload,T), at(Truck,T,Node), not delivery(Node).
:- do(Truck,unload,T), truck_load(Truck,T,L), L < 1.
:- do(Truck,unload,T), demand(Node,T,D), at(Truck,T,Node), D < 1.

% charging
:- do(Truck,charge,T), at(Truck,T,Node), not charger(Node).
:- do(Truck,charge,T), battery(Truck,T,B), B >= battery_capacity.

% moving
:- do(Truck,move(I,J),T), at(Truck,T,Node), Node!=I.
:- do(Truck,move(I,J),T), battery(Truck,T,B), B < 1.
:- do(Truck1,move(I,J),T), at(Truck2,T+1,J), Truck1!=Truck2.
:- do(Truck1,move(I1,J1),T), do(Truck2,move(I2,J2),T), Truck1!=Truck2, I1=J2, I2=J1.

% extra constraints
:- truck_load(Truck,T,L), load_capacity(Truck,Cap), L > Cap, time(T).
:- truck_load(Truck,T,L), L < 0, time(T), truck(Truck).
:- battery(Truck,T,B), B > battery_capacity, time(T), truck(Truck).
:- battery(Truck,T,B), B < 0, time(T), truck(Truck).
:- supply(T,S), S < 0, time(T).
:- demand(Node,T,D), D < 0, time(T), delivery(Node).

%*
GOAL CONDITIONS:
- Constraints that express that the goal must be reached

Explanation (max 100 words):
[WRITE YOUR EXPLANATION HERE]
*%




%*
OPTIMIZATION:
- Express an optimization statement to find a solution within the smallest
  number of time steps

Explanation (max 100 words):
[WRITE YOUR EXPLANATION HERE]
*%




%*
OPTIONAL: ADDITIONAL RULES
- If you add anything to your program that doesn't fit in any of the other
  headings, put it here.

Explanation (max 100 words):
[WRITE YOUR EXPLANATION HERE]
*%

%*
PRETTY PRINTING
*%
#script (python)

import clingo
from collections import defaultdict

def on_model(model):
	truck_ids = [1,2,3]
	actions = dict()
	time_steps = set()

	truck_states = defaultdict(dict)
	demand = defaultdict(dict)
	supply = dict()

	for atom in model.symbols(atoms=True):
		if atom.name == "do":
			truck = atom.arguments[0].number
			action = atom.arguments[1]
			time = atom.arguments[2].number

			if actions.get((time,truck)):
				print("Double assignment")
			actions[(time,truck)] = action

			time_steps.add(time)

		if atom.name == "at":
			truck = atom.arguments[0].number
			time = atom.arguments[1].number
			node = atom.arguments[2].number

			if truck_states[(time,truck)].get("at"):
				print("Double assignment")
			truck_states[(time,truck)]["at"] = node

		if atom.name == "truck_load":
			truck = atom.arguments[0].number
			time = atom.arguments[1].number
			load = atom.arguments[2].number

			if truck_states[(time,truck)].get("load"):
				print("Double assignment")
			truck_states[(time,truck)]["load"] = load

		if atom.name == "battery":
			truck = atom.arguments[0].number
			time = atom.arguments[1].number
			battery = atom.arguments[2].number

			if truck_states[(time,truck)].get("battery"):
				print("Double assignment")
			truck_states[(time,truck)]["battery"] = battery

		if atom.name == "supply":
			time = atom.arguments[0].number

			if supply.get(time):
				print("Double assignment")
			supply[time] = atom.arguments[1].number

		if atom.name == "demand":
			node = atom.arguments[0].number
			time = atom.arguments[1].number

			if demand[node].get(time):
				print("Double assignment")
			demand[node][time] = atom.arguments[2].number

	print("Pretty printed answer set:")
	time_steps = list(time_steps)
	time_steps.sort()
	print(time_steps)
	for time in time_steps:
		print(f"TIME STEP {time}")
		for truck in truck_ids:
			print(f"  TRUCK {truck}:")
			action =  actions[(time,truck)]
			print(f"    Action:   {action}")
			node =    truck_states[(time,truck)]['at']
			print(f"    Location: {node}")
			battery = truck_states[(time,truck)]['battery']
			print(f"    Battery:  {battery}")
			load =    truck_states[(time,truck)]['load']
			print(f"    Load:     {load}")
		print(f"  Supply:   {supply[time]}")
		print(f"  Demand8:  {demand[8][time]}")
		print(f"  Demand11: {demand[11][time]}")
		print()

	# last_timestep = str(int(time_steps[-1]) + 1)
	# for truck in truck_ids:
	# 	node = truck_states[last_timestep + ',' + truck]['node']
	# 	battery = truck_states[last_timestep + ',' + truck]['battery']
	# 	packages = truck_states[last_timestep + ',' + truck]['packages']
	# 	print(f"- At time step {last_timestep} truck {truck} was at node {node} with battery {battery}, packages {packages}.")
	# print(f"- At time step {last_timestep} warehouse had {supply[last_timestep]} packages.")


def main(prg):
	prg.ground([("base", [])])
	prg.solve(on_model=on_model)

#end.

%*
THE END
*%
