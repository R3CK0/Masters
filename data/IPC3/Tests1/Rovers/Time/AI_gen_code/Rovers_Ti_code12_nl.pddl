(define (domain Rover)
    (:requirements :typing :durative-actions :fluents :duration-inequalities)
    (:types rover waypoint store camera mode lander objective)

    (:predicates 
        (at ?x - rover ?y - waypoint) 
        (at_lander ?x - lander ?y - waypoint)
        (can_traverse ?r - rover ?x - waypoint ?y - waypoint)
        (equipped_for_soil_analysis ?r - rover)
        ; Other predicates...

        ; Add the predicate
        (equipped_for_soil_analysis ?r - rover)
        (full ?s - store)
        (empty ?s - store)
        (at_soil_sample ?w - waypoint)
        (have_soil_analysis ?r - rover ?w - waypoint)
        ; Other predicates...
    )

    ; Add the sample-soil action
    (:durative-action sample_soil
        :parameters (?x - rover ?s - store ?p - waypoint)
        :duration (= ?duration 10)
        :condition (and 
            (over all (at ?x ?p)) 
            (at start (at ?x ?p)) 
            (at start (at_soil_sample ?p)) 
            (at start (equipped_for_soil_analysis ?x)) 
            (at start (>= (energy ?x) 3)) 
            (at start (store_of ?s ?x)) 
            (at start (empty ?s))
        )
        :effect (and 
            (at end (full ?s))
            (at start (decrease (energy ?x) 3))
            (at end (have_soil_analysis ?x ?p))
            (at end (not (at_soil_sample ?p)))
        )
    )

    ; Other existing actions and definitions...
)
