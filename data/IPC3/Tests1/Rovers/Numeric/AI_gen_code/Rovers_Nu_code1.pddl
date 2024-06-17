(define (domain Rover)
  (:requirements :typing :fluents)
  (:types rover waypoint store camera mode lander objective)

  (:predicates 
    (at ?r - rover ?w - waypoint) 
    (at_lander ?l - lander ?w - waypoint)
    (can_traverse ?x - waypoint ?y - waypoint)
    (equipped_for_imaging ?r - rover)
    (equipped_for_soil_analysis ?r - rover)
    (equipped_for_rock_analysis ?r - rover)
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
    (calibration_target ?c - camera ?o - objective)
    (on_board ?c - camera ?r - rover)
    (channel_free ?l - lander)
    (in_sun ?w - waypoint)
  )

  (:functions 
    (energy ?r - rover) 
    (recharges) 
  )

  (:action navigate
    :parameters (?r - rover ?wp_from - waypoint ?wp_to - waypoint) 
    :precondition (and 
      (can_traverse ?wp_from ?wp_to) 
      (available ?r) 
      (at ?r ?wp_from) 
      (visible ?wp_from ?wp_to) 
      (>= (energy ?r) 8)
    )
    :effect (and 
      (decrease (energy ?r) 8) 
      (not (at ?r ?wp_from)) 
      (at ?r ?wp_to)
    )
  )

  (:action recharge
    :parameters (?r - rover ?w - waypoint)
    :precondition (and 
      (at ?r ?w) 
      (in_sun ?w) 
      (<= (energy ?r) 80)
    )
    :effect (and 
      (increase (energy ?r) 20) 
      (increase (recharges) 1) 
    )
  )

  (:action sample_soil
    :parameters (?r - rover ?s - store ?w - waypoint)
    :precondition (and 
      (at ?r ?w) 
      (equipped_for_soil_analysis ?r) 
      (>= (energy ?r) 3) 
      (at_soil_sample ?w) 
      (store_of ?s ?r) 
      (empty ?s)
    )
    :effect (and 
      (not (empty ?s)) 
      (full ?s) 
      (decrease (energy ?r) 3) 
      (have_soil_analysis ?r ?w) 
      (not (at_soil_sample ?w))
    )
  )

  (:action sample_rock
    :parameters (?r - rover ?s - store ?w - waypoint)
    :precondition (and 
      (at ?r ?w) 
      (equipped_for_rock_analysis ?r)
      (>= (energy ?r) 5) 
      (at_rock_sample ?w) 
      (store_of ?s ?r) 
      (empty ?s)
    )
    :effect (and 
      (not (empty ?s)) 
      (full ?s) 
      (decrease (energy ?r) 5) 
      (have_rock_analysis ?r ?w) 
      (not (at_rock_sample ?w))
    )
  )

  (:action drop
    :parameters (?r - rover ?s - store)
    :precondition (and 
      (store_of ?s ?r) 
      (full ?s)
    )
    :effect (and 
      (not (full ?s)) 
      (empty ?s)
    )
  )

  (:action calibrate
    :parameters (?r - rover ?c - camera ?o - objective ?w - waypoint)
    :precondition (and 
      (equipped_for_imaging ?r) 
      (>= (energy ?r) 2) 
      (calibration_target ?c ?o) 
      (at ?r ?w) 
      (visible_from ?o ?w) 
      (on_board ?c ?r)
    )
    :effect (and 
      (decrease (energy ?r) 2) 
      (calibrated ?c ?r) 
    )
  )

  (:action take_image
    :parameters (?r - rover ?w - waypoint ?o - objective ?c - camera ?m - mode)
    :precondition (and 
      (calibrated ?c ?r) 
      (on_board ?c ?r) 
      (equipped_for_imaging ?r) 
      (supports ?c ?m) 
      (visible_from ?o ?w) 
      (at ?r ?w) 
      (>= (energy ?r) 1)
    )
    :effect (and 
      (have_image ?r ?o ?m) 
      (not (calibrated ?c ?r)) 
      (decrease (energy ?r) 1)
    )
  )

  (:action communicate_soil_data
    :parameters (?r - rover ?l - lander ?wp_soil - waypoint ?wp_rover - waypoint ?wp_lander - waypoint)
    :precondition (and 
      (at ?r ?wp_rover) 
      (at_lander ?l ?wp_lander) 
      (have_soil_analysis ?r ?wp_soil) 
      (visible ?wp_rover ?wp_lander) 
      (available ?r) 
      (channel_free ?l) 
      (>= (energy ?r) 4)
    )
    :effect (and 
      (decrease (energy ?r) 4) 
      (communicated_soil_data ?wp_soil)
    )
  )

  (:action communicate_rock_data
    :parameters (?r - rover ?l - lander ?wp_rock - waypoint ?wp_rover - waypoint ?wp_lander - waypoint)
    :precondition (and 
      (at ?r ?wp_rover) 
      (at_lander ?l ?wp_lander) 
      (have_rock_analysis ?r ?wp_rock) 
      (visible ?wp_rover ?wp_lander) 
      (available ?r) 
      (channel_free ?l) 
      (>= (energy ?r) 4)
    )
    :effect (and 
      (decrease (energy ?r) 4) 
      (communicated_rock_data ?wp_rock)
    )
  )

  (:action communicate_image_data
    :parameters (?r - rover ?l - lander ?o - objective ?m - mode ?wp_rover - waypoint ?wp_lander - waypoint)
    :precondition (and 
      (at ?r ?wp_rover) 
      (at_lander ?l ?wp_lander) 
      (have_image ?r ?o ?m) 
      (visible ?wp_rover ?wp_lander) 
      (available ?r) 
      (channel_free ?l) 
      (>= (energy ?r) 6)
    )
    :effect (and 
      (decrease (energy ?r) 6) 
      (communicated_image_data ?o ?m)
    )
  )

)
