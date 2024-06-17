(define (domain Rover)
    (:requirements :typing :fluents :durative-actions)
    (:types rover waypoint store camera mode lander objective)

    (:predicates 
        ;; Position and traversal
        (at ?x - rover ?y - waypoint) 
        (at_lander ?x - lander ?y - waypoint)
        (can_traverse ?r - rover ?x - waypoint ?y - waypoint)

        ;; Equipment status
        (equipped_for_soil_analysis ?r - rover)
        (equipped_for_rock_analysis ?r - rover)
        (equipped_for_imaging ?r - rover)

        ;; Storage state
        (empty ?s - store)
        (full ?s - store)
        
        ;; Analysis possession
        (have_rock_analysis ?r - rover ?w - waypoint)
        (have_soil_analysis ?r - rover ?w - waypoint)

        ;; Calibration and image data
        (calibrated ?c - camera ?r - rover) 
        (supports ?c - camera ?m - mode)
        (have_image ?r - rover ?o - objective ?m - mode)

        ;; Communication states
        (available ?r - rover)
        (visible ?w - waypoint ?p - waypoint)
        (visible_from ?o - objective ?w - waypoint)
        (communicated_soil_data ?w - waypoint)
        (communicated_rock_data ?w - waypoint)
        (communicated_image_data ?o - objective ?m - mode)
        (channel_free ?l - lander)
        
        ;; Sample locations
        (at_soil_sample ?w - waypoint)
        (at_rock_sample ?w - waypoint)

        ;; Camera and storage
        (store_of ?s - store ?r - rover)
        (calibration_target ?i - camera ?o - objective)
        (on_board ?i - camera ?r - rover)
        
        ;; Recharging
        (in_sun ?w - waypoint)
    )

    (:functions 
        (energy ?r - rover) 
        (recharge-rate ?x - rover)
    )

    ;; Modified and new actions:
    
    ;; Navigate action with visibility check and energy requirement
    (:durative-action navigate
        :parameters (?x - rover ?y - waypoint ?z - waypoint)
        :duration (= ?duration 5)
        :condition (and 
            (at start (can_traverse ?x ?y ?z))
            (at start (available ?x))
            (at start (at ?x ?y))
            (over all (>= (energy ?x) 8))
            (at start (visible ?y ?z)))
        :effect (and 
            (at end (not (at ?x ?y)))
            (at end (at ?x ?z))
            (at end (decrease (energy ?x) 8)))
    )

    ;; Recharge action with dynamic duration
    (:durative-action recharge
        :parameters (?x - rover ?w - waypoint)
        :duration (= ?duration (/ (- 80 (energy ?x)) (recharge-rate ?x)))
        :condition (and 
            (at start (at ?x ?w))
            (at start (in_sun ?w))
            (over all (<= (energy ?x) 80)))
        :effect (at end (increase (energy ?x) (* (- 80 (energy ?x)) (recharge-rate ?x))))
    )

    ;; Sample soil action
    (:durative-action sample_soil
        :parameters (?x - rover ?s - store ?p - waypoint)
        :duration (= ?duration 10)
        :condition (and 
            (at start (at ?x ?p))
            (over all (at_soil_sample ?p))
            (over all (equipped_for_soil_analysis ?x))
            (at start (store_of ?s ?x))
            (at start (empty ?s))
            (over all (>= (energy ?x) 3)))
        :effect (and 
            (at end (not (empty ?s)))
            (at end (full ?s))
            (at end (decrease (energy ?x) 3))
            (at end (have_soil_analysis ?x ?p))
            (at end (not (at_soil_sample ?p))))
    )

    ;; Sample rock action
    (:durative-action sample_rock
        :parameters (?x - rover ?s - store ?p - waypoint)
        :duration (= ?duration 8)
        :condition (and 
            (at start (at ?x ?p))
            (over all (at_rock_sample ?p))
            (over all (equipped_for_rock_analysis ?x))
            (at start (store_of ?s ?x))
            (at start (empty ?s))
            (over all (>= (energy ?x) 5)))
        :effect (and 
            (at end (not (empty ?s)))
            (at end (full ?s))
            (at end (decrease (energy ?x) 5))
            (at end (have_rock_analysis ?x ?p))
            (at end (not (at_rock_sample ?p))))
    )

    ;; Drop action (instantaneous)
    (:action drop
        :parameters (?x - rover ?y - store)
        :precondition (and 
            (store_of ?y ?x)
            (full ?y))
        :effect (and
            (not (full ?y))
            (empty ?y))
    )

    ;; Calibrate action
    (:durative-action calibrate
        :parameters (?r - rover ?i - camera ?t - objective ?w - waypoint)
        :duration (= ?duration 5)
        :condition (and 
            (at start (equipped_for_imaging ?r))
            (at start (calibration_target ?i ?t))
            (at start (at ?r ?w))
            (over all (visible_from ?t ?w))
            (at start (on_board ?i ?r))
            (over all (>= (energy ?r) 2)))
        :effect (and 
            (at end (calibrated ?i ?r))
            (at end (decrease (energy ?r) 2)))
    )

    ;; Take image action
    (:durative-action take_image
        :parameters (?r - rover ?p - waypoint ?o - objective ?i - camera ?m - mode)
        :duration (= ?duration 7)
        :condition (and 
            (at start (calibrated ?i ?r))
            (at start (on_board ?i ?r))
            (over all (equipped_for_imaging ?r))
            (over all (supports ?i ?m))
            (over all (visible_from ?o ?p))
            (at start (at ?r ?p))
            (over all (>= (energy ?r) 1)))
        :effect (and 
            (at end (have_image ?r ?o ?m))
            (at end (decrease (energy ?r) 1))
            (at end (not (calibrated ?i ?r))))
    )

    ;; Communicate soil data action
    (:durative-action communicate_soil_data
        :parameters (?r - rover ?l - lander ?p - waypoint ?x - waypoint ?y - waypoint)
        :duration (= ?duration 10)
        :condition (and 
            (at start (at ?r ?x))
            (at start (at_lander ?l ?y))
            (over all (have_soil_analysis ?r ?p))
            (over all (visible ?x ?y))
            (at start (available ?r))
            (over all (channel_free ?l))
            (over all (>= (energy ?r) 4)))
        :effect (and 
            (at start (not (available ?r)))
            (at end (communicated_soil_data ?p))
            (at end (available ?r))
            (at start (not (channel_free ?l)))
            (at end (channel_free ?l))
            (at end (decrease (energy ?r) 4)))
    )

    ;; Communicate rock data action
    (:durative-action communicate_rock_data
        :parameters (?r - rover ?l - lander ?p - waypoint ?x - waypoint ?y - waypoint)
        :duration (= ?duration 10)
        :condition (and 
            (at start (at ?r ?x))
            (at start (at_lander ?l ?y))
            (over all (have_rock_analysis ?r ?p))
            (over all (visible ?x ?y))
            (at start (available ?r))
            (over all (channel_free ?l))
            (over all (>= (energy ?r) 4)))
        :effect (and 
            (at start (not (available ?r)))
            (at end (communicated_rock_data ?p))
            (at end (available ?r))
            (at start (not (channel_free ?l)))
            (at end (channel_free ?l))
            (at end (decrease (energy ?r) 4)))
    )

    ;; Communicate image data action
    (:durative-action communicate_image_data
        :parameters (?r - rover ?l - lander ?o - objective ?m - mode ?x - waypoint ?y - waypoint)
        :duration (= ?duration 15)
        :condition (and 
            (at start (at ?r ?x))
            (at start (at_lander ?l ?y))
            (over all (have_image ?r ?o ?m))
            (over all (visible ?x ?y))
            (at start (available ?r))
            (over all (channel_free ?l))
            (over all (>= (energy ?r) 6)))
        :effect (and 
            (at start (not (available ?r)))
            (at start (not (channel_free ?l)))
            (at end (communicated_image_data ?o ?m))
            (at end (available ?r))
            (at end (channel_free ?l))
            (at end (decrease (energy ?r) 6)))
    )
)

