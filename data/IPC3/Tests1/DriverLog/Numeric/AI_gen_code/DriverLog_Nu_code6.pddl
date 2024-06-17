(define (domain driverlog)
  (:requirements :typing :fluents) 
  (:types
    location locatable - object
    driver truck obj - locatable
  )

  (:predicates 
    (at ?obj - locatable ?loc - location)
    (in ?obj1 - obj ?obj - truck)
    (driving ?d - driver ?v - truck)
    (link ?x ?y - location)
    (path ?x ?y - location)
    (empty ?v - truck)
  )

  (:functions
    (time-to-walk ?l1 ?l2 - location)
    (time-to-drive ?l1 ?l2 - location)
    (driven)
    (walked)
  )

  (:action WALK
    :parameters
      (?driver - driver ?loc-from - location ?loc-to - location)
    :precondition
      (and (at ?driver ?loc-from) (path ?loc-from ?loc-to))
    :effect
      (and (not (at ?driver ?loc-from)) (at ?driver ?loc-to)
        (increase (walked) (time-to-walk ?loc-from ?loc-to)))
  )

  (:action LOAD-TRUCK
    :parameters
      (?obj - obj ?truck - truck ?location - location)
    :precondition
      (and (at ?truck ?location) (at ?obj ?location) (empty ?truck))
    :effect
      (and (not (at ?obj ?location))
           (in ?obj ?truck))
  )

  (:action UNLOAD-TRUCK
    :parameters
      (?obj - obj ?truck - truck ?location - location)
    :precondition
      (and (at ?truck ?location) (in ?obj ?truck))
    :effect
      (and (at ?obj ?location)
           (not (in ?obj ?truck)))
  )

  (:action BOARD-TRUCK
    :parameters
      (?driver - driver ?truck - truck ?location - location)
    :precondition
      (and (at ?driver ?location) (empty ?truck) (at ?truck ?location))
    :effect
      (and (driving ?driver ?truck) (not (at ?driver ?location)) (not (empty ?truck)))
  )

  (:action DISEMBARK-TRUCK
    :parameters
      (?driver - driver ?truck - truck ?location - location)
    :precondition
      (and (driving ?driver ?truck) (at ?truck ?location))
    :effect
      (and (not (driving ?driver ?truck)) (at ?driver ?location) (empty ?truck))
  )

  (:action DRIVE-TRUCK
    :parameters
      (?driver - driver ?truck - truck ?loc-from - location ?loc-to - location)
    :precondition
      (and (driving ?driver ?truck) (at ?truck ?loc-from) (link ?loc-from ?loc-to))
    :effect
      (and (at ?truck ?loc-to) (not (at ?truck ?loc-from))
           (increase (driven) (time-to-drive ?loc-from ?loc-to)))
  )

)
