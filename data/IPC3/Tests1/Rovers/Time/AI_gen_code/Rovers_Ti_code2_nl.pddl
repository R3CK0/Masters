(:predicates ... 
   (equipped_for_soil_analysis ?r - rover)
   ...
)

(:durative-action sample_soil
    :parameters (?r - rover ?s - store ?w - waypoint)
    :duration (= ?duration 10)
    :condition (and (at start (at ?r ?w))
                    (at start (>= (energy ?r) 3))
                    (at start (equipped_for_soil_analysis ?r))
                    (at start (at_soil_sample ?w))
                    (at start (store_of ?s ?r))
                    (at start (empty ?s))
               )
    :effect (and (at end (have_soil_analysis ?r ?w))
                 (at end (not (at_soil_sample ?w)))
                 (at start (decrease (energy ?r) 3))
                 (at end (not (empty ?s)))
                 (at end (full ?s))
            )
)
