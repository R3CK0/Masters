(define (domain Rover)
(:requirements :typing :fluents)
(:types rover waypoint store camera mode lander objective)

(:predicates 
    (at ?x - rover ?y - waypoint) 
    (at_lander ?x - lander ?y - waypoint)
    (can_traverse ?r - rover ?x - waypoint ?y - waypoint)
    (equipped_for_imaging ?r - rover)
    (equipped_for_soil_analysis ?r - rover)
    (equipped_for_rock_analysis ?r - rover)
    (empty ?s - store)
    (full ?s - store)
    (supports ?c - camera ?m - mode)
    (available ?r - rover)
    (visible ?w - waypoint ?p - waypoint)
    (have_image ?r - rover ?o - objective ?m - mode)
    (communicated_image_data ?o - objective ?m - mode)
    (at_soil_sample ?w - waypoint)
    (at_rock_sample ?w - waypoint)
    (visible_from ?o - objective ?w - waypoint)
    (store_of ?s - store ?r - rover)
    (calibration_target ?i - camera ?o - objective)
    (on_board ?i - camera ?r - rover)
    (channel_free ?l - lander)
    (in_sun ?w - waypoint)
    (calibrated ?i - camera)
    (have_soil_analysis ?r - rover ?w - waypoint)
    (have_rock_analysis ?r - rover ?w - waypoint)
    (communicated_soil_data ?w - waypoint)
    (communicated_rock_data ?w - waypoint)
)

(:functions (energy ?r - rover) (recharges) )

(:action navigate
    :parameters (?x - rover ?y - waypoint ?z - waypoint) 
    :precondition (and (can_traverse ?x ?y ?z) (available ?x) (at ?x ?y) 
                (visible ?y ?z) (>= (energy ?x) 8))
    :effect (and (decrease (energy ?x) 8) (not (at ?x ?y)) (at ?x ?z))
)

(:action recharge
    :parameters (?x - rover ?w - waypoint)
    :precondition (and (at ?x ?w) (in_sun ?w) (<= (energy ?x) 80))
    :effect (and (increase (energy ?x) 20) (increase (recharges) 1))
)

(:action drop
    :parameters (?x - rover ?y - store)
    :precondition (and (store_of ?y ?x) (full ?y))
    :effect (and (not (full ?y)) (empty ?y))
)

(:action take_image
    :parameters (?r - rover ?p - waypoint ?o - objective ?i - camera ?m - mode)
    :precondition (and (calibrated ?i ?r) (on_board ?i ?r) 
                       (equipped_for_imaging ?r) (supports ?i ?m)
                       (visible_from ?o ?p) (at ?r ?p) (>= (energy ?r) 1))
    :effect (and (have_image ?r ?o ?m) (not (calibrated ?i ?r)) 
                 (decrease (energy ?r) 1))
)

(:action communicate_image_data
    :parameters (?r - rover ?l - lander ?o - objective ?m - mode ?x - waypoint ?y - waypoint)
    :precondition (and (at ?r ?x) (at_lander ?l ?y) 
                       (have_image ?r ?o ?m) (visible ?x ?y) 
                       (available ?r) (channel_free ?l) (>= (energy ?r) 6))
    :effect (and (not (available ?r)) (not (channel_free ?l))
                 (channel_free ?l) (communicated_image_data ?o ?m)
                 (available ?r) (decrease (energy ?r) 6))
)

(:action sample-soil
    :parameters (?r - rover ?s - store ?w - waypoint)
    :precondition (and (at ?r ?w) (>= (energy ?r) 3) 
                       (at_soil_sample ?w) (equipped_for_soil_analysis ?r) 
                       (store_of ?s ?r) (empty ?s))
    :effect (and (not (at_soil_sample ?w)) (not (empty ?s)) 
                 (full ?s) (have_soil_analysis ?r ?w) 
                 (decrease (energy ?r) 3))
)

(:action sample-rock
    :parameters (?r - rover ?s - store ?w - waypoint)
    :precondition (and (at ?r ?w) (>= (energy ?r) 5) 
                       (at_rock_sample ?w) (equipped_for_rock_analysis ?r) 
                       (store_of ?s ?r) (empty ?s))
    :effect (and (not (at_rock_sample ?w)) (not (empty ?s)) 
                 (full ?s) (have_rock_analysis ?r ?w) 
                 (decrease (energy ?r) 5))
)

(:action calibrate
    :parameters (?r - rover ?i - camera ?o - objective ?w - waypoint)
    :precondition (and (at ?r ?w) (>= (energy ?r) 2) 
                       (equipped_for_imaging ?r) (on_board ?i ?r) 
                       (calibration_target ?i ?o) (visible_from ?o ?w))
    :effect (and (calibrated ?i) (decrease (energy ?r) 2))
)

(:action communicate_soil_data
    :parameters (?r - rover ?l - lander ?x - waypoint ?y - waypoint ?w - waypoint)
    :precondition (and (at ?r ?x) (at_lander ?l ?y) (have_soil_analysis ?r ?w) 
                       (visible ?x ?y) (available ?r) (channel_free ?l) 
                       (>= (energy ?r) 4))
    :effect (and (communicated_soil_data ?w) (decrease (energy ?r) 4))
)

(:action communicate_rock_data
    :parameters (?r - rover ?l - lander ?x - waypoint ?y - waypoint ?w - waypoint)
    :precondition (and (at ?r ?x) (at_lander ?l ?y) (have_rock_analysis ?r ?w) 
                       (visible ?x ?y) (available ?r) (channel_free ?l) 
                       (>= (energy ?r) 4))
    :effect (and (communicated_rock_data ?w) (decrease (energy ?r) 4))
)
)

