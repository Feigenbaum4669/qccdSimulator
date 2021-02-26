# Introduction
This file contains documentation on how the JSON representation of the TI-QCCD device topolgy works.

# Json file
The JSON file contains three main objects. The first one, "_adjacency_", represents how the nodes of the graph representing the device topology are connected. For example, 
```
adjacency.1: ["5"]
adjacency.5: ["2", "3"]
```
means that node with id $1$ has an outgoing edge to node $5$, and node $5$ has two outgoing edges to nodes $2$ and $3$.

The second object, "_trap_", contains all the information related to the traps on the device. Fisrt of all, the attribute ```trap.capacity: "integer" ``` shows how many ions at the same time there can be in a trap. The attribute ``` trap.traps: []``` contains an array of objects, each one of them with information about an individual trap. Each object contains the following data, illustrated with an example:
```
{
Trap's id:
id: "1"

The ion chain inside the trap at the beginning, they should be specified in the correct order:
chain: ["q1","q2","q3"] 

The following attributes exist to represent in which end of the trap the ions are, and which shuttle they are connected to. Assuming a trap has two ends, we have:
"end0": {
    "qubit": "q1",
    "shuttle": ""
},
"end1": {
    "qubit": "q3",
    "shuttle": "s1"
}
This would mean that "q1" is next to an end of the trap in which the shuttle is incoming, so new ions would come from this side and be added to the ion chain next to "q1". On the other hand, "q3" has the outgoing shuttle "s1" next to it so, if necessary, it could leave the ion trap without the need of being swapped with another qubit. See how the qubits in the previous data structure match with the first and last qubits in the "chain" attribute.
```

The next object is "_junction_", which has the attribute ```junction.junctions: [] ``` containing an array of objects, each one containing information for each individual junction. Said information is the following, showed by an example:
```
Junction's id:
"id": "4",

Type of junction:
"type": "T"
```

Finally, the last object "_shuttle_" contains the attribute ```shuttle.shuttles: [] ``` which has information of each individual shuttle. An example of the information it may contain is:
```
Shuttle id:
"id": "s1",

Id of the node it goes out from:
"from": "1",

Id of the node it goes to:
"to": "5",
```