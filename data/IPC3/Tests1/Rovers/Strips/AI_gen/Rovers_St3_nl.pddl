(define (domain Rover)
(:requirements :typing)
(:types rover waypoint store camera mode lander objective)

(:predicates (at ?r - rover ?w - waypoint) 
             (at_lander ?l - lander ?w - waypoint)
             (can_traverse ?r - rover ?w1 - waypoint ?w2 - waypoint)
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
             (visible ?w1 - waypoint ?w2 - waypoint)
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
 :parameters (?r - rover ?w1 - waypoint ?w2 - waypoint) 
 :precondition (and (can_traverse ?r ?w1 ?w2) (available ?r) (at ?r ?w1) (visible ?w1 ?w2))
 :effect (and (not (at ?r ?w1)) (at ?r ?w2))
)

(:action drop
 :parameters (?r - rover ?s - store)
 :precondition (and (store_of ?s ?r) (full ?s))
 :effect (and (not (full ?s)) (empty ?s))
)

(:action take_image
 :parameters (?r - rover ?w - waypoint ?o - objective ?i - camera ?m - mode)
 :precondition (and (calibrated ?i ?r) (on_board ?i ?r) (equipped_for_imaging ?r) (supports ?i ?m) (visible_from ?o ?w) (at ?r ?w))
 :effect (and (have_image ?r ?o ?m)(not (calibrated ?i ?r)))
)

(:action sample_soil
 :parameters (?r - rover ?w - waypoint ?s - store)
 :precondition (and (at ?r ?w) (equipped_for_soil_analysis ?r) (at_soil_sample ?w) (store_of ?s ?r) (empty ?s))
 :effect (and (not (empty ?s)) (full ?s) (have_soil_analysis ?r ?w))
)

(:action sample_rock
 :parameters (?r - rover ?w - waypoint ?s - store)
 :precondition (and (at ?r ?w) (equipped_for_rock_analysis ?r) (at_rock_sample ?w) (store_of ?s ?r) (empty ?s))
 :effect (and (not (empty ?s)) (full ?s) (have_rock_analysis ?r ?w))
)

(:action calibrate
 :parameters (?r - rover ?i - camera ?o - objective ?w - waypoint)
 :precondition (and (at ?r ?w) (on_board ?i ?r) (calibration_target ?i ?o) (visible_from ?o ?w))
 :effect (calibrated ?i ?r)
)

(:action communicate_rock_data
 :parameters (?r - rover ?l - lander ?w - waypoint)
 :precondition (and (at ?r ?w)(at_lander ?l ?w)(have_rock_analysis ?r ?w)
                    (available ?r)(channel_free ?l))
 :effect (and (not (available ?r))(not (channel_free ?l))(communicated_rock_data ?w)(available ?r)(channel_free ?l))
)

(:action communicate_image_data
 :parameters (?r - rover ?l - lander ?o - objective ?m - mode ?w - waypoint)
 :precondition (and (at ?r ?w)(at_lander ?l ?w)(have_image ?r ?o ?m)(available ?r)(channel_free ?l))
 :effect (and (not (available ?r))(not (channel_free ?l))(communicated_image_data ?o ?m)(available ?r)(channel_free ?l))
)

)
