(define (domain Rover)
(:requirements :typing :durative-actions)
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

(:durative-action navigate
    :parameters (?x - rover ?y - waypoint ?z - waypoint) 
    :duration (= ?duration 5)
    :condition (and 
        (over all (can_traverse ?x ?y ?z)) 
        (at start (available ?x)) 
        (at start (at ?x ?y)) 
        (over all (visible ?y ?z))
    )
    :effect (and 
        (at start (not (at ?x ?y))) 
        (at end (at ?x ?z))
    )
)

(:durative-action sample_soil
    :parameters (?r - rover ?s - store ?w - waypoint)
    :duration (= ?duration 5)
    :condition (and 
        (at start (at ?r ?w))
        (at start (at_soil_sample ?w))
        (over all (equipped_for_soil_analysis ?r))
        (at start (store_of ?s ?r))
        (at start (empty ?s))
    )
    :effect (and 
        (at end (not (empty ?s)))
        (at end (full ?s))
        (at end (have_soil_analysis ?r ?w))
        (at end (not (at_soil_sample ?w)))
    )
)

(:durative-action sample_rock
    :parameters (?r - rover ?s - store ?w - waypoint)
    :duration (= ?duration 5)
    :condition (and 
        (at start (at ?r ?w))
        (at start (at_rock_sample ?w))
        (over all (equipped_for_rock_analysis ?r))
        (at start (store_of ?s ?r))
        (at start (empty ?s))
    )
    :effect (and 
        (at end (not (empty ?s)))
        (at end (full ?s))
        (at end (have_rock_analysis ?r ?w))
        (at end (not (at_rock_sample ?w)))
    )
)

(:durative-action drop
    :parameters (?r - rover ?s - store)
    :duration (= ?duration 1)
    :condition (and 
        (at start (store_of ?s ?r)) 
        (at start (full ?s))
    )
    :effect (and 
        (at end (not (full ?s)))
        (at end (empty ?s))
    )
)

(:durative-action calibrate
    :parameters (?r - rover ?c - camera ?o - objective ?w - waypoint)
    :duration (= ?duration 3)
    :condition (and 
        (at start (at ?r ?w))
        (over all (equipped_for_imaging ?r))
        (at start (on_board ?c ?r))
        (at start (calibration_target ?c ?o))
        (over all (visible_from ?o ?w))
    )
    :effect (and 
        (at end (calibrated ?c ?r))
    )
)

(:durative-action take_image
    :parameters (?r - rover ?w - waypoint ?o - objective ?c - camera ?m - mode)
    :duration (= ?duration 7)
    :condition (and 
        (over all (calibrated ?c ?r))
        (at start (on_board ?c ?r))
        (over all (equipped_for_imaging ?r))
        (over all (supports ?c ?m))
        (over all (visible_from ?o ?w))
        (over all (at ?r ?w))
    )
    :effect (and 
        (at end (have_image ?r ?o ?m))
        (at end (not (calibrated ?c ?r)))
    )
)

(:durative-action communicate_soil_data
    :parameters (?r - rover ?l - lander ?w_r - waypoint ?w_l - waypoint ?w_s - waypoint)
    :duration (= ?duration 10)
    :condition (and 
        (over all (at ?r ?w_r))
        (over all (at_lander ?l ?w_l))
        (at start (have_soil_analysis ?r ?w_s))
        (at start (visible ?w_r ?w_l))
        (at start (available ?r))
        (at start (channel_free ?l))
    )
    :effect (and 
        (at start (not (available ?r)))
        (at start (not (channel_free ?l)))
        (at end (channel_free ?l))
        (at end (communicated_soil_data ?w_s))
        (at end (available ?r))
    )
)

(:durative-action communicate_rock_data
    :parameters (?r - rover ?l - lander ?w_r - waypoint ?w_l - waypoint ?w_rock - waypoint)
    :duration (= ?duration 10)
    :condition (and 
        (over all (at ?r ?w_r))
        (over all (at_lander ?l ?w_l))
        (at start (have_rock_analysis ?r ?w_rock))
        (at start (visible ?w_r ?w_l))
        (at start (available ?r))
        (at start (channel_free ?l))
    )
    :effect (and 
        (at start (not (available ?r)))
        (at start (not (channel_free ?l)))
        (at end (channel_free ?l))
        (at end (communicated_rock_data ?w_rock))
        (at end (available ?r))
    )
)

(:durative-action communicate_image_data
    :parameters (?r - rover ?l - lander ?o - objective ?m - mode ?x - waypoint ?y - waypoint)
    :duration (= ?duration 15)
    :condition (and 
        (over all (at ?r ?x))
        (over all (at_lander ?l ?y))
        (at start (have_image ?r ?o ?m))
        (at start (visible ?x ?y))
        (at start (available ?r))
        (at start (channel_free ?l))
    )
    :effect (and 
        (at start (not (available ?r)))
        (at start (not (channel_free ?l)))
        (at end (channel_free ?l))
        (at end (communicated_image_data ?o ?m))
        (at end (available ?r))
    )
)

)
