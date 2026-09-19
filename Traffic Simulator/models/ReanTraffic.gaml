/**
* Name: ReanTraffic
* Author: dina
* Tags: traffic, gis, multi-agent, urban-mobility
*/

model ReanTraffic

global {
    file shape_file_roads <- shape_file("../includes/road.shp");
    file shape_file_buildings <- shape_file("../include/buildings.shp");
    file shape_file_safe_zones <- shape_file("../include/sage_zones.shp");
    geometry shape <- envelope(shape_file_roads); 	 

    int number_of_vehicles <- 40;   
    float average_congestion <- 0.0;  

    graph road_network;  
    map<road, float> road_weights;

    init {
        if (shape_file_roads = nil or shape_file_roads.contents = nil) {
            error "FATAL: road.shp could not be loaded from ../includes/."; 
        }

        // 1. Ingest roads
        create road from: shape_file_roads;
        road_network <- as_edge_graph(road); 

        if (road_network = nil) {
            error "FATAL: road_network construction failed.";
        }

        // 2. Synthesize Buildings along road edges (Origins & Destinations)
        ask 20 among road {
            create building {
                // Place building slightly offset from the road line
                location <- any_location_in(self.shape) + {rnd(-15, 15), rnd(-15, 15)};
                type <- flip(0.5) ? "residential" : "work";
            }
        }

        // 3. Synthesize Traffic Lights at road intersections/junctions
        ask 10 among road {
            create traffic_light {
                location <- first(self.shape.points); // Snap to edge endpoint
            }
        }

        // 4. Spawn vehicles at residential buildings
        create vehicle number: number_of_vehicles { 
            building home <- one_of(building where (each.type = "residential"));
            if (home != nil) {
                location <- home.location;
            } else {
                location <- any_location_in(one_of(road));
            }
        } 
    }

    reflex recalculate when: every(5 #cycle) { 
        road_weights <- road as_map (each :: (each.shape.perimeter * (1.0 + each.congestion)));
        average_congestion <- mean(road collect each.congestion);
    }
}

// -------------------------------------------------------------
// ENVIRONMENT & INFRASTRUCTURE SPECIES
// -------------------------------------------------------------

species road {
    float capacity; 
    int current_vehicles <- 0;  
    float congestion <- 0.0; 

    init { 
        capacity <- max(1.0, shape.perimeter / 15.0 #m); 
    }

    reflex update_congestion { 
        current_vehicles <- length(vehicle at_distance 2.0 #m); 
        congestion <- min(1.0, current_vehicles / capacity); 
    }

    aspect base { 
        rgb road_color <- (congestion > 0.7) ? #red : ((congestion > 0.3) ? #orange : #green);
        draw shape color: road_color width: 2.5; 
    }
}

species building {
    string type <- "residential"; // "residential" or "work"

    aspect base {
        rgb b_color <- (type = "residential") ? #skyblue : #coral;
        draw square(12 #m) color: b_color border: #black;
    }
}

species traffic_light {
    int green_time <- 20;
    int red_time   <- 15;
    string state   <- "green"; // "green" or "red"

    reflex cycle_light {
        int t <- cycle mod (green_time + red_time);
        state <- (t < green_time) ? "green" : "red";
    }

    aspect base {
        rgb light_color <- (state = "green") ? #lime : #red;
        draw circle(4.0 #m) color: light_color border: #black;
    }
}

// -------------------------------------------------------------
// MOBILE ACTOR SPECIES
// -------------------------------------------------------------

species vehicle skills: [moving] {
    rgb color <- rnd_color(255);  
    float max_speed <- (25 + rnd(15)) #km/#h; 
    point target; 

    reflex select_trip when: target = nil {
        // Select an attractive destination (e.g., commute to a work building)
        building dest <- one_of(building where (each.type = "work"));
        if (dest != nil) {
            path p <- path_between(road_network, location, dest.location);
            if (p != nil and length(p.edges) > 0) {
                target <- dest.location;
            }
        }
    }

    reflex drive when: target != nil {
        // Check for red light right ahead
        traffic_light nearby_signal <- traffic_light closest_to self;
        if (nearby_signal != nil and nearby_signal.state = "red") {
            if ((self distance_to nearby_signal) < 8.0 #m and (self towards nearby_signal) < 45) {
                speed <- 0.0;
                return; // Stop and yield this cycle
            }
        }

        speed <- max_speed;
        do goto target: target on: road_network move_weights: road_weights;  

        if ((location distance_to target) < 4.0 #m) { 
            target <- nil; 
        }
    }

    aspect base {
        draw triangle(4.5 #m) color: color rotate: heading + 90 border: #black; 
    }	
}

// -------------------------------------------------------------
// EXPERIMENT
// -------------------------------------------------------------

experiment TrafficSimulation type: gui {
    parameter "Initial Vehicles" var: number_of_vehicles min: 10 max: 100 category: "Traffic Setup";	

    output { 
        monitor "Active Fleet" value: length(vehicle); 
        monitor "Avg Congestion Index" value: average_congestion;

        display main_display type: opengl background: #white {
            species road aspect: base; 
            species building aspect: base;
            species traffic_light aspect: base;
            species vehicle aspect: base;  
        }

        display Analytics refresh: every(5 #cycle) {
            chart "Average Congestion Index" type: series style: line {
                data "Congestion" value: average_congestion color: #red;
            }
        }
    }
}