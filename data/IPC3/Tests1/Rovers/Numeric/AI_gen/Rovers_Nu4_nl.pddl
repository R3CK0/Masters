(define (domain Rover)
  (:requirements :typing :fluents)
  (:types rover waypoint store camera mode lander objective)

  (:predicates 
    (at ?x - rover ?y - waypoint)
    (at_lander ?x - lander ?y - waypoint)
    (can_traverse ?r - rover ?x - waypoint ?y - waypoint)
    (equipped_for_imaging ?r - rover)
    (equipped_for_soil_analysis ?r - rover) ;; Added predicate
    (equipped_for_rock_analysis ?r - rover) ;; Added predicate
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
    (calibrated ?i - camera) ;; Added predicate
    (have_soil_analysis ?r - rover) ;; Added predicate
    (have_rock_analysis ?r - rover) ;; Added predicate
    (communicated_rock_data ?r - rover) ;; Added predicate
    (communicated_soil_data ?r - rover)  ;; Added predicate
  )

  (:functions 
    (energy ?r - rover)
    (recharges)
  )

  ;; Existing actions omitted for brevity...

  ;; New Actions:

  ;; Action to sample soil
  (:action sample-soil
    :parameters (?r - rover ?w - waypoint)
    :precondition (and 
      (at ?r ?w)
      (at_soil_sample ?w)
      (equipped_for_soil_analysis ?r)
      (>= (energy ?r) 3)
    )
    :effect (and 
      (decrease (energy ?r) 3)
      (have_soil_analysis ?r)
    )
  )

  ;; Action to sample rock
  (:action sample-rock
    :parameters (?r - rover ?w - waypoint)
    :precondition (and 
      (at ?r ?w)
      (at_rock_sample ?w)
      (equipped_for_rock_analysis ?r)
      (>= (energy ?r) 5)
    )
    :effect (and 
      (decrease (energy ?r) 5)
      (have_rock_analysis ?r)
    )
  )

  ;; Action to communicate rock data
  (:action communicate_rock_data
    :parameters (?r - rover ?l - lander ?x - waypoint ?y - waypoint)
    :precondition (and 
      (at ?r ?x)
      (at_lander ?l ?y)
      (have_rock_analysis ?r)
      (visible ?x ?y)
      (available ?r)
      (channel_free ?l)
      (>= (energy ?r) 4)
    )
    :effect (and 
      (not (available ?r))
      (not (channel_free ?l))
      (channel_free ?l)
      (communicated_rock_data ?r)
      (available ?r)
      (decrease (energy ?r) 4)
    )
  )

  ;; Action to communicate soil data
  (:action communicate_soil_data
    :parameters (?r - rover ?l - lander ?x - waypoint ?y - waypoint)
    :precondition (and 
      (at ?r ?x)
      (at_lander ?l ?y)
      (have_soil_analysis ?r)
      (visible ?x ?y)
      (available ?r)
      (channel_free ?l)
      (>= (energy ?r) 4)
    )
    :effect (and 
      (not (available ?r))
      (not (channel_free ?l))
      (channel_free ?l)
      (communicated_soil_data ?r)
      (available ?r)
      (decrease (energy ?r) 4)
    )
  )

  ;; Action to calibrate camera
  (:action calibrate
    :parameters (?r - rover ?i - camera)
    :precondition (and 
      (on_board ?i ?r)
      (calibration_target ?i ?o)
      (>= (energy ?r) 2)
    )
    :effect (and 
      (decrease (energy ?r) 2)
      (calibrated ?i)
    )
  )
)
