(:predicates
    ...
    (equipped_for_soil_analysis ?r - rover)
    ...
)

(:action sample_soil
    :parameters (?r - rover ?s - store ?w - waypoint)
    :precondition (and (at ?r ?w) (at_soil_sample ?w)
                       (equipped_for_soil_analysis ?r)
                       (store_of ?s ?r) (empty ?s))
    :effect (and (not (at_soil_sample ?w)) (have_soil_analysis ?r ?w)
                 (not (empty ?s)) (full ?s))
)
