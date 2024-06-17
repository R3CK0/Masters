(:action sample_soil
 :parameters (?x - rover ?s - store ?p - waypoint)
 :precondition (and (at ?x ?p) (at_soil_sample ?p) (equipped_for_soil_analysis ?x) (store_of ?s ?x) (empty ?s))
 :effect (and (not (empty ?s)) (full ?s) (have_soil_analysis ?x ?p) (not (at_soil_sample ?p)))
)
