(define (domain Rover)
(:requirements :typing :durative-actions)
(:types rover waypoint store camera mode lander objective)

(:predicates 
    (at ?x - rover ?y - waypoint) 
    (at_lander ?x - lander ?y - waypoint)
    (can_traverse ?x - waypoint ?y - waypoint)
    (equipped_for_soil_analysis ?x - rover)
    (equipped_for_rock_analysis ?x - rover)
    (equipped_for_air_analysis ?x - rover)
    (equipped_for_imaging ?x - rover)
    (empty ?x - store)
    (have_rock_analysis ?x - rover ?y - waypoint)
    (have_soil_analysis ?x - rover ?y - waypoint)
    (have_air_analysis ?x - rover ?y - waypoint)
    (full ?x - store)
    (calibrated ?x - camera ?y - rover)
    (supports ?x - camera ?y - mode)
    (available ?x - rover)
    (visible ?x - waypoint ?y - waypoint)
    (have_image ?x - rover ?y - objective ?z - mode)
    (communicated_soil_data ?x - waypoint)
    (communicated_rock_data ?x - waypoint)
    (communicated_air_data ?x - waypoint)
    (communicated_image_data ?x - objective ?y - mode)
    (at_soil_sample ?x - waypoint)
    (at_rock_sample ?x - waypoint)
    (at_air_sample ?x - waypoint)
    (visible_from ?x - objective ?y - waypoint)
    (store_of ?x - store ?y - rover)
    (calibration_target ?x - camera ?y - objective)
    (on_board ?x - camera ?y - rover)
    (channel_free ?x - lander)
)

(:durative-action navigate
    :parameters (?x - rover ?y - waypoint ?z - waypoint) 
    :duration (= ?duration 5)
    :condition (and 
        (over all (can_traverse ?y ?z)) 
        (at start (available ?x)) 
        (at start (at ?x ?y)) 
        (over all (visible ?y ?z)))
    :effect (and 
        (at start (not (at ?x ?y))) 
        (at end (at ?x ?z))
    )
)

(:durative-action sample_soil
    :parameters (?x - rover ?s - store ?p - waypoint)
    :duration (= ?duration 10)
    :condition (and 
        (over all (at ?x ?p)) 
        (at start (at ?x ?p)) 
        (at start (at_soil_sample ?p)) 
        (at start (equipped_for_soil_analysis ?x)) 
        (at start (store_of ?s ?x)) 
        (at start (empty ?s))
    )
    :effect (and 
        (at start (not (empty ?s))) 
        (at end (full ?s)) 
        (at end (have_soil_analysis ?x ?p)) 
        (at end (not (at_soil_sample ?p)))
    )
)

(:durative-action sample_rock
    :parameters (?x - rover ?s - store ?p - waypoint)
    :duration (= ?duration 8)
    :condition (and 
        (over all (at ?x ?p)) 
        (at start (at ?x ?p)) 
        (at start (at_rock_sample ?p)) 
        (at start (equipped_for_rock_analysis ?x)) 
        (at start (store_of ?s ?x)) 
        (at start (empty ?s))
    )
    :effect (and 
        (at start (not (empty ?s))) 
        (at end (full ?s)) 
        (at end (have_rock_analysis ?x ?p))  
        (at end (not (at_rock_sample ?p)))
    )
)

(:durative-action sample_air
    :parameters (?x - rover ?s - store ?p - waypoint)
    :duration (= ?duration 8)
    :condition (and 
        (over all (at ?x ?p)) 
        (at start (at ?x ?p)) 
        (at start (at_air_sample ?p)) 
        (at start (equipped_for_air_analysis ?x)) 
        (at start (store_of ?s ?x)) 
        (at start (empty ?s))
    )
    :effect (and 
        (at start (not (empty ?s))) 
        (at end (full ?s)) 
        (at end (have_air_analysis ?x ?p))  
        (at end (not (at_air_sample ?p)))
    )
)

(:durative-action drop
    :parameters (?x - rover ?y - store)
    :duration (= ?duration 1)
    :condition (and 
        (at start (store_of ?y ?x)) 
        (at start (full ?y))
    )
    :effect (and 
        (at end (not (full ?y))) 
        (at end (empty ?y))
    )
)

(:durative-action calibrate
    :parameters (?x - rover ?c - camera ?o - objective ?w - waypoint)
    :duration (= ?duration 5)
    :condition (and 
        (at start (equipped_for_imaging ?x)) 
        (at start (calibration_target ?c ?o)) 
        (over all (at ?x ?w)) 
        (at start (visible_from ?o ?w)) 
        (at start (on_board ?c ?x))
    )
    :effect (at end (calibrated ?c ?x)) 
)

(:durative-action take_image
    :parameters (?x - rover ?p - waypoint ?o - objective ?c - camera ?m - mode)
    :duration (= ?duration 7)
    :condition (and 
        (over all (calibrated ?c ?x)) 
        (at start (on_board ?c ?x))
        (over all (equipped_for_imaging ?x))
        (over all (supports ?c ?m))
        (over all (visible_from ?o ?p))
        (over all (at ?x ?p))
    )
    :effect (and 
        (at end (have_image ?x ?o ?m)) 
        (at end (not (calibrated ?c ?x)))
    )
)

(:durative-action communicate_soil_data
    :parameters (?x - rover ?l - lander ?p - waypoint ?y - waypoint ?z - waypoint)
    :duration (= ?duration 10)
    :condition (and 
        (over all (at ?x ?y)) 
        (over all (at_lander ?l ?z)) 
        (at start (have_soil_analysis ?x ?p)) 
        (at start (visible ?y ?z)) 
        (at start (available ?x)) 
        (at start (channel_free ?l))
    )
    :effect (and 
        (at start (not (available ?x))) 
        (at start (not (channel_free ?l))) 
        (at end (channel_free ?l))
        (at end (communicated_soil_data ?p))
        (at end (available ?x))
    )
)

(:durative-action communicate_rock_data
    :parameters (?x - rover ?l - lander ?p - waypoint ?y - waypoint ?z - waypoint)
    :duration (= ?duration 10)
    :condition (and 
        (over all (at ?x ?y)) 
        (over all (at_lander ?l ?z)) 
        (at start (have_rock_analysis ?x ?p)) 
        (at start (visible ?y ?z)) 
        (at start (available ?x)) 
        (at start (channel_free ?l))
    )
    :effect (and 
        (at start (not (available ?x))) 
        (at start (not (channel_free ?l))) 
        (at end (channel_free ?l))
        (at end (communicated_rock_data ?p))
        (at end (available ?x))
    )
)

(:durative-action communicate_air_data
    :parameters (?x - rover ?l - lander ?p - waypoint ?y - waypoint ?z - waypoint)
    :duration (= ?duration 10)
    :condition (and 
        (over all (at ?x ?y)) 
        (over all (at_lander ?l ?z)) 
        (at start (have_air_analysis ?x ?p)) 
        (at start (visible ?y ?z)) 
        (at start (available ?x)) 
        (at start (channel_free ?l))
    )
    :effect (and 
        (at start (not (available ?x))) 
        (at start (not (channel_free ?l))) 
        (at end (channel_free ?l))
        (at end (communicated_air_data ?p))
        (at end (available ?x))
    )
)

(:durative-action communicate_image_data
    :parameters (?x - rover ?l - lander ?o - objective ?m - mode ?y - waypoint ?z - waypoint)
    :duration (= ?duration 15)
    :condition (and 
        (over all (at ?x ?y)) 
        (over all (at_lander ?l ?z)) 
        (at start (have_image ?x ?o ?m)) 
        (at start (visible ?y ?z)) 
        (at start (available ?x)) 
        (at start (channel_free ?l))
    )
    :effect (and 
        (at start (not (available ?x))) 
        (at start (not (channel_free ?l))) 
        (at end (channel_free ?l)) 
        (at end (communicated_image_data ?o ?m)) 
        (at end (available ?x))
    )
)

)
