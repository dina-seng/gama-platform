# Concept Note: Sheep Movements and Herd Behavior

## 1. Project Overview & Context
This project explores how macro-level herd behavior and distinct pathway tracks emerge from the micro-level, individual behaviors of sheep. Sheep naturally display herding behaviors by following and keeping close to each other. These behaviors are evolutionary responses to predator risks and resource use optimization. When a herd moves through a heterogeneous landscape filled with obstacles, the collective movement results in the emergence of pathways.

### Core Research Question
How does the spatial distribution of obstacles influence the emergence of frequently used pathways?

## 2. Core Simulation Dynamics
To answer this question, we will build an Agent-Based Model (ABM) in GAMA with the following elements:
*   **The Environment (Grid):** A grid-based spatial topology to track "tramping" (the number of times a sheep passes over a specific area).
*   **The Agents (Sheep):** Autonomous agents that follow flocking rules (Cohesion, Separation, Alignment) to simulate herd dynamics.
*   **The Obstacles:** Static agents placed in the environment that sheep must navigate around.

## 3. Project Extensions
The project scope includes four progressive extensions to deepen the complexity:
*   **Extension 1:** Implement variations in obstacle types (different sizes, shapes, or levels of complexity) to assess their impacts on pathway emergence and utilization.
*   **Extension 2:** Introduce environmental factors (e.g., specific vegetation attracting sheep, topography making paths difficult) to examine interactions with obstacle distribution.
*   **Extension 3:** Introduce a 'dog' species to scare the sheep, observing how this disrupts herding and interacts with the spatial distribution.
*   **Extension 4 (Bonus):** Add real-time adaptation mechanisms allowing sheep to dynamically adjust pathway choices based on evolving obstacle distributions and environmental conditions.

## 4. GAML Implementation Strategy
*   **Grid Species:** We will use a `grid` to act as the ground. Each cell will have a `tramping_level` attribute that increases when a sheep steps on it, dynamically changing the cell's color to draw the pathways.
*   **Flocking Logic:** We will utilize GAMA's continuous space movement and implement custom reflexes or the built-in `boids` architecture to handle the herding behavior.
*   **Multi-Species Interaction:** The `dog` and `sheep` will use distance-based operators to trigger flee behaviors, overriding standard movement algorithms.
