# Introduction
This file contains documentation on how the JSON representation of the TI-QCCD device topolgy works.

# Topology JSON file
The JSON file contains three main objects. The first one, "_adjacency_", represents how the nodes of the graph representing the device topology are connected. For example, 
```
adjacency.1: ["5"]
adjacency.5: ["2", "3"]
```
means that node with id $1$ has an edge to node $5$, and node $5$ has two edges to nodes $2$ and $3$. Note that, since the edges are undirected, one could write `x: [y]` or `y: [x]`. It doesn't make any difference, just be sure that you don't write it in both ways at the same time (that would be repeating edges, which will throw an error).

The second object, "_trap_", contains all the information related to the traps on the device. Fisrt of all, the attribute ```trap.capacity: "integer" ``` shows how many ions at the same time there can be in a trap. The attribute ``` trap.traps: []``` contains an array of objects, each one of them with information about an individual trap. Each object contains the following data, illustrated with an example:
```
{
Trap's id:
id: "1"

The following attribute exists to represent to which shuttle an end of a junction is connected to. Assuming a trap has two ends, we have:
"end0": ""
"end1": "s1"

This would mean that end0 is not connected to any junction, while end1 is connected to shuttle with id "s1".
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

One of the ends of the shuttle:
"end0": "1",

The other end:
"end1": "5",
```

# Operation duration JSON file
In this file, one should specify how long it takes (in milliseconds) to perform each low-level device operation. The format is the following:
```
{
    "operation1": time1,
    "operation2": time2
}
```
The device operations are the following:
* ```load```: Loads an ion into the device
* ```linear_transport```: Moves ions between traps/junctions through a shuttle.
* ```junction_transport```: Moves ions around a junction.
* ```swap```: Physically swaps the positions of two ions.
* ```split```: Splits an ion from an ion chain.
* ```merge```: Merges an ion in an ion chain.
* ```Rz```: Single qubit Z-rotation.
* ```Rxy```: Single qubit XY-plane rotation.
* ```XX```: Two qubit XX-rotation.
* ```ZZ```: Two qubit ZZ-rotation.
