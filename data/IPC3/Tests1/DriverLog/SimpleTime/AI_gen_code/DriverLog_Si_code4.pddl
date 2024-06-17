(define (domain driverlog)
  (:requirements :typing :durative-actions)
  (:types           
    location locatable - object
    driver truck obj - locatable)
  
  (:predicates 
    (at ?obj - locatable ?loc - location)
    (in ?obj1 - obj ?obj - truck)
    (driving ?d - driver ?v - truck)
    (link ?x ?y - location)
    (path ?x ?y - location)
    (empty ?v - truck))

  (:durative-action WALK
    :parameters
      (?driver - driver ?loc-from - location ?loc-to - location)
    :duration (= ?duration 20)
    :condition
      (and (at start (at ?driver ?loc-from)) 
	   (at start (path ?loc-from ?loc-to)))
    :effect
      (and (at start (not (at ?driver ?loc-from)))
           (at end (at ?driver ?loc-to))))

  (:action LOAD_TRUCK
    :parameters
      (?obj - obj ?truck - truck ?loc - location)
    :precondition
      (and (at ?obj ?loc) (at ?truck ?loc) (empty ?truck))
    :effect
      (and (not (at ?obj ?loc))
           (in ?obj ?truck)))

  (:action UNLOAD_TRUCK
    :parameters
      (?obj - obj ?truck - truck ?loc - location)
    :precondition
      (and (in ?obj ?truck) (at ?truck ?loc))
    :effect
      (and (at ?obj ?loc)
           (not (in ?obj ?truck))))

  (:action BOARD_TRUCK
    :parameters
      (?driver - driver ?truck - truck ?loc - location)
    :precondition
      (and (at ?driver ?loc) (empty ?truck) (at ?truck ?loc))
    :effect
      (and (not (at ?driver ?loc))
           (driving ?driver ?truck)
           (not (empty ?truck))))

  (:action DISEMBARK_TRUCK
    :parameters
      (?driver - driver ?truck - truck ?loc - location)
    :precondition
      (and (driving ?driver ?truck) (at ?truck ?loc))
    :effect
      (and (at ?driver ?loc)
           (not (driving ?driver ?truck))
           (empty ?truck)))

  (:action DRIVE_TRUCK
    :parameters
      (?driver - driver ?truck - truck ?loc-from - location ?loc-to - location)
    :precondition
      (and (driving ?driver ?truck) (at ?truck ?loc-from) (link ?loc-from ?loc-to))
    :effect
      (and (not (at ?truck ?loc-from))
           (at ?truck ?loc-to)))
)
