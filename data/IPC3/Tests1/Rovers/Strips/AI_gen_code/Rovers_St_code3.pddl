(define (domain Rover)
(:requirements :typing)
(:types rover waypoint store camera mode lander objective)

(:predicates 
    (at ?x - rover ?y - waypoint) 
    (at_lander ?x - lander ?y - waypoint)
    (can_traverse ?r - rover ?x - waypoint ?y - waypoint)
    (equipped_for_soil_analysis ?r - rover)
    (equipped_for_rock_analysis ?r - rover)
    (equipped_for_imaging ?r - rover)
    (empty ?s - store)
    (have_rock_analysis ?r - rover ?w - waypoint)
    (have_soil_analysis ?r - rover ?w - waypoint)
    (full ?s - store)
    (calibrated ?c - camera ?r - rover) 
    (supports ?c - camera ?m - mode)
    (available ?r - rover)
    (visible ?w - waypoint ?p - waypoint)
    (have_image ?r - rover ?o - objective ?m - mode)
    (communicated_soil_data ?w - waypoint)
    (communicated_rock_data ?w - waypoint)
    (communicated_image_data ?o - objective ?m - mode)
    (at_soil_sample ?w - waypoint)
    (at_rock_sample ?w - waypoint)
    (visible_from ?o - objective ?w - waypoint)
    (store_of ?s - store ?r - rover)
    (calibration_target ?i - camera ?o - objective)
    (on_board ?i - camera ?r - rover)
    (channel_free ?l - lander)
)

(:action navigate
    :parameters (?x - rover ?y - waypoint ?z - waypoint) 
    :precondition (and 
        (can_traverse ?x ?y ?z) 
        (at ?x ?y) 
        (visible ?y ?z)
    )
    :effect (and 
        (not (at ?x ?y)) 
        (at ?x ?z)
    )
)

(:action drop
    :parameters (?x - rover ?y - store)
    :precondition (and 
        (store_of ?y ?x) 
        (full ?y)
    )
    :effect (and 
        (not (full ?y)) 
        (empty ?y)
    )
)

(:action sample_soil
    :parameters (?r - rover ?s - store ?w - waypoint)
    :precondition (and 
        (at ?r ?w)
        (at_soil_sample ?w)
        (equipped_for_soil_analysis ?r)
        (store_of ?s ?r)
        (empty ?s)
    )
    :effect (and 
        (not (empty ?s)) 
        (full ?s)
        (have_soil_analysis ?r ?w)
        (not (at_soil_sample ?w))
    )
)

(:action sample_rock
    :parameters (?r - rover ?s - store ?w - waypoint)
    :precondition (and 
        (at ?r ?w)
        (at_rock_sample ?w)
        (equipped_for_rock_analysis ?r)
        (store_of ?s ?r)
        (empty ?s)
    )
    :effect (and 
        (not (empty ?s)) 
        (full ?s)
        (have_rock_analysis ?r ?w)
        (not (at_rock_sample ?w))
    )
)

(:action take_image
    :parameters (?r - rover ?p - waypoint ?o - objective ?i - camera ?m - mode)
    :precondition (and 
        (calibrated ?i ?r)
        (on_board ?i ?r)
        (equipped_for_imaging ?r)
        (supports ?i ?m)
        (visible_from ?o ?p)
        (at ?r ?p)
    )
    :effect (and 
        (have_image ?r ?o ?m) 
        (not (calibrated ?i ?r))
    )
)

(:action calibrate
    :parameters (?r - rover ?c - camera ?o - objective ?w - waypoint)
    :precondition (and 
        (at ?r ?w)
        (equipped_for_imaging ?r)
        (on_board ?c ?r)
        (calibration_target ?c ?o)
        (visible_from ?o ?w)
    )
    :effect (calibrated ?c ?r)
)

(:action communicate_soil_data
    :parameters (?r - rover ?l - lander ?p - waypoint ?x - waypoint ?y - waypoint)
    :precondition (and 
        (at ?r ?x)
        (at_lander ?l ?y)
        (have_soil_analysis ?r ?p)
        (visible ?x ?y)
        (available ?r)
        (channel_free ?l)
    )
    :effect (communicated_soil_data ?p)
)

(:action communicate_rock_data
    :parameters (?r - rover ?l - lander ?p - waypoint ?x - waypoint ?y - waypoint)
    :precondition (and 
        (at ?r ?x)
        (at_lander ?l ?y)
        (have_rock_analysis ?r ?p)
        (visible ?x ?y)
        (available ?r)
        (channel_free ?l)
    )
    :effect (communicated_rock_data ?p)
)

(:action communicate_image_data
    :parameters (?r - rover ?l - lander ?o - objective ?m - mode ?x - waypoint ?y - waypoint)
    :precondition (and 
        (at ?r ?x)
        (at_lander ?l ?y)
        (have_image ?r ?o ?m)
        (visible ?x ?y)
        (available ?r)
        (channel_free ?l)
    )
    :effect (and 
        (communicated_image_data ?o ?m) 
        (not (have_image ?r ?o ?m))
    )
)

)
