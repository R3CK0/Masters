(define (domain driverlog)
  (:requirements :typing :fluents) 
  (:types
    location locatable - object
    driver truck obj - locatable)

  (:predicates
    (at ?obj - locatable ?loc - location)
    (in ?obj1 - obj ?obj - truck)
    (driving ?d - driver ?v - truck)
    (link ?x ?y - location) (path ?x ?y - location)
    (empty ?v - truck))

  (:functions
    (time-to-walk ?l1 ?l2 - location)
    (time-to-drive ?l1 ?l2 - location)
    (driven)
    (walked))

  (:action BOARD-TRUCK
    :parameters (?d - driver ?v - truck ?loc - location)
    :precondition
      (and (at ?d ?loc) (at ?v ?loc) (empty ?v))
    :effect
      (and (not (empty ?v)) (driving ?d ?v) (not (at ?d ?loc))))

  (:action DISEMBARK-TRUCK
    :parameters (?d - driver ?v - truck ?loc - location)
    :precondition
      (and (driving ?d ?v) (at ?v ?loc))
    :effect
      (and (empty ?v) (not (driving ?d ?v)) (at ?d ?loc)))

  (:action LOAD-TRUCK
    :parameters (?obj - obj ?truck - truck ?loc - location)
    :precondition
      (and (at ?truck ?loc) (at ?obj ?loc))
    :effect
      (and (not (at ?obj ?loc)) (in ?obj ?truck)))

  (:action UNLOAD-TRUCK
    :parameters (?obj - obj ?truck - truck ?loc - location)
    :precondition
      (and (at ?truck ?loc) (in ?obj ?truck))
    :effect
      (and (not (in ?obj ?truck)) (at ?obj ?loc)))

  (:action WALK
    :parameters (?driver - driver ?loc-from - location ?loc-to - location)
    :precondition
      (and (at ?driver ?loc-from) (path ?loc-from ?loc-to))
    :effect
      (and (not (at ?driver ?loc-from)) (at ?driver ?loc-to)
            (increase (walked) (time-to-walk ?loc-from ?loc-to))))

)
