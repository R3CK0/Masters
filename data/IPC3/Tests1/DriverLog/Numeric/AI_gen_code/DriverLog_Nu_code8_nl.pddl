(define (domain driverlog)
  (:requirements :typing :fluents) 
  (:types
    location locatable - object
    driver truck obj - locatable)

  (:predicates 
    (at ?obj - locatable ?loc - location)
    (in ?obj1 - obj ?obj - truck)
    (link ?x ?y - location)
    (path ?x ?y - location)
    (empty ?v - truck)
    (driving ?d - driver ?t - truck))

  (:functions
    (time-to-walk ?l1 ?l2 - location)
    (time-to-drive ?l1 ?l2 - location)
    (driven)
    (walked))

  (:action LOAD-TRUCK
    :parameters
      (?obj - obj ?truck - truck ?loc - location)
    :precondition
      (and (at ?truck ?loc) (at ?obj ?loc))
    :effect
      (and (not (at ?obj ?loc)) (in ?obj ?truck)))

  (:action UNLOAD-TRUCK
    :parameters
      (?obj - obj ?truck - truck ?loc - location)
    :precondition
      (and (at ?truck ?loc) (in ?obj ?truck))
    :effect
      (and (not (in ?obj ?truck)) (at ?obj ?loc)))

  (:action BOARD-TRUCK
    :parameters
      (?driver - driver ?truck - truck ?loc - location)
    :precondition
      (and (at ?truck ?loc) (at ?driver ?loc) (empty ?truck))
    :effect
      (and (not (at ?driver ?loc)) (not (empty ?truck)) (driving ?driver ?truck)))

  (:action DISEMBARK-TRUCK
    :parameters
      (?driver - driver ?truck - truck ?loc - location)
    :precondition
      (and (at ?truck ?loc) (driving ?driver ?truck))
    :effect
      (and (at ?driver ?loc) (empty ?truck) (not (driving ?driver ?truck))))

  (:action DRIVE-TRUCK
    :parameters
      (?truck - truck ?loc-from - location ?loc-to - location ?driver - driver)
    :precondition
      (and (at ?truck ?loc-from) (link ?loc-from ?loc-to) (driving ?driver ?truck))
    :effect
      (and (not (at ?truck ?loc-from)) (at ?truck ?loc-to)
            (increase (driven) (time-to-drive ?loc-from ?loc-to))))

  (:action WALK
    :parameters
      (?driver - driver ?loc-from - location ?loc-to - location)
    :precondition
      (and (at ?driver ?loc-from) (path ?loc-from ?loc-to))
    :effect
      (and (not (at ?driver ?loc-from)) (at ?driver ?loc-to)
            (increase (walked) (time-to-walk ?loc-from ?loc-to))))
)
