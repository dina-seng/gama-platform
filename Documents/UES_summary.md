# Concept Note: Urban Evacuation Simulation Using GAMA Platform

## 1. Project Overview & Concept Note

### Context
As urban populations grow, cities face increasing risks from natural and human-made disasters (e.g., floods, fires, chemical spills). Effective disaster management requires robust evacuation plans. Traditional static planning often fails to account for the dynamic, unpredictable nature of human movement and traffic congestion during a crisis.

### Objective
The **Urban Evacuation Simulation** project leverages Agent-Based Modeling (ABM) to simulate how a city's population evacuates to designated "Safe Zones" during an emergency. By modeling each vehicle as an independent agent navigating a real-world geographic road network, we can observe emergent macro-level phenomena such as traffic jams and bottleneck formations.

### Core Dynamics
*   **The Environment:** A spatial representation of a city including Buildings (origins), Safe Zones (destinations), and a Road Network (the graph on which agents travel).
*   **The Agents (Vehicles):** Autonomous entities that spawn at buildings and must find the most efficient route to a Safe Zone.
*   **Dynamic Routing:** The road network dynamically updates its "weight" (travel time) based on real-time congestion. Agents recalculate their routes to avoid bottlenecks.
*   **Analytics:** Real-time monitoring of the evacuation timeline, measuring how quickly the active fleet drops as agents successfully reach safety.

### Why This Matters
This simulation acts as a digital twin for urban planners. It allows stakeholders to test "what-if" scenarios: 
*   *What if we close this major artery?* 
*   *What if we stagger evacuation times?* 
*   *Are three safe zones enough, or do we need five?*

---

## 2. Basics of the GAML Language

This project is built using **GAMA** (GIS Agent-based Modeling Architecture) and programmed in **GAML** (GAMA Modeling Language). GAML is an agent-oriented language specifically designed to handle complex spatial data and complex agent behaviors.

A standard GAML model is divided into three fundamental pillars:

### A. The `global` Block
Think of this as the "God" or "Environment" level. It is where the simulation is initialized, global variables are stored, and time is managed.
*   **GIS Integration:** GAML easily ingests real-world data using `shape_file()`.
*   **Graphs:** Spatial networks are created effortlessly using `as_edge_graph()`.
*   **Initialization:** The `init { ... }` block runs exactly once at cycle 0 to spawn the initial state of the world (creating roads, buildings, and the first agents).

### B. The `species` Blocks
A `species` is a blueprint for an agent (similar to a Class in Object-Oriented Programming). It defines an agent's attributes, behaviors, and appearance.
*   **Attributes:** Variables specific to the agent (e.g., `float max_speed;`, `safe_zone target;`).
*   **Skills:** Built-in modules that give agents advanced capabilities. For example, `skills: [moving]` gives an agent the built-in variables `speed`, `heading`, and the action `goto`.
*   **Reflexes (`reflex`):** The core behavioral loop. A reflex is a block of code that an agent executes at every step (cycle) of the simulation if its condition is met (e.g., `reflex drive when: target_location != nil { ... }`).
*   **Aspects (`aspect`):** How the agent is drawn on the 2D or 3D map (e.g., drawing a triangle for a car, or a colored line for a road).

### C. The `experiment` Block
This defines the user interface, parameters, and output analytics. A single model can have multiple experiments to test different scenarios without changing the core code.
*   **Displays:** Defining 2D/3D maps (`type: opengl`) and layering species on top of each other.
*   **Monitors:** Real-time variables displayed on the dashboard.
*   **Charts:** Live-updating graphs (e.g., time-series data showing the number of evacuated vehicles).

---

## 3. GAML Syntax Examples Used in Phase 1

Here is how we applied GAML basics to achieve our Phase 1 evacuation model:

**1. Instantiating Agents from GIS Data:**
```gaml
create road from: shape_file_roads;
```
*In one line of code, GAMA reads the shapefile, creates a `road` agent for every line segment, and automatically parses its geometry.*

**2. Context-Aware Spawning (The `ask` Command):**
```gaml
ask building {
    create vehicle {
        location <- myself.location;
    }
}
```
*We ask every building to create a vehicle inside itself. `myself` refers to the building (the one doing the asking), ensuring the vehicle spawns exactly at the building's coordinates.*

**3. Dynamic Pathfinding:**
```gaml
do goto target: target_location on: road_network move_weights: road_weights;
```
*Because the vehicle has the `moving` skill, it can use the `goto` action. It automatically calculates the shortest path on the `road_network` graph, factoring in the dynamically updating `road_weights` (congestion).*

**4. Agent Death (Cleanup):**
```gaml
if (location distance_to target_location < 10.0 #m) { 
    do die; 
}
```
*When an agent achieves its goal, `do die;` removes it from memory, optimizing simulation performance.*

---

## 4. Summary of Phase 1 & Next Steps

**What we achieved in Phase 1:**
We successfully established a macroscopic traffic model. We generated a synthetic urban environment (Buildings, Roads, Safe Zones), spawned agents, and utilized graph-based pathfinding to simulate an evacuation. The live analytics correctly track the flow of agents from "fleeing" to "safe," demonstrating a working proof-of-concept.

**Next Steps (Phase 2):**
In Phase 2, we will transition from macroscopic routing (dots on lines) to **microscopic traffic simulation**. 
We will replace the basic `moving` skill with GAMA's `advanced_driving` plugin. This will introduce:
*   Physical vehicle dimensions (length, width).
*   Lanes and lane-changing behavior.
*   Car-following physics (Intelligent Driver Model - IDM).
*   Right-of-way and intersection collision avoidance.
