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

  (:action BOARD-TRUCK
    :parameters
      (?driver - driver
       ?truck - truck
       ?location - location)
    :precondition
      (and (at ?truck ?location)
           (at ?driver ?location)
           (empty ?truck))
    :effect
      (and (not (at ?driver ?location))
           (driving ?driver ?truck)
           (not (empty ?truck)))
  )

  (:action DISEMBARK-TRUCK
    :parameters
      (?driver - driver
       ?truck - truck
       ?location - location)
    :precondition
      (and (at ?truck ?location)
           (driving ?driver ?truck))
    :effect
      (and (not (driving ?driver ?truck))
           (at ?driver ?location)
           (empty ?truck))
  )

  (:action DRIVE-TRUCK
    :parameters
      (?truck - truck
       ?loc-from - location
       ?loc-to - location
       ?driver - driver)
    :precondition
      (and (at ?truck ?loc-from)
           (driving ?driver ?truck)
           (link ?loc-from ?loc-to))
    :effect
      (and (not (at ?truck ?loc-from))
           (at ?truck ?loc-to)
           (increase (driven) (time-to-drive ?loc-from ?loc-to)))
  )

  (:action WALK
    :parameters
      (?driver - driver
       ?loc-from - location
       ?loc-to - location)
    :precondition
      (and (at ?driver ?loc-from) (path ?loc-from ?loc-to))
    :effect
      (and (not (at ?driver ?loc-from))
           (at ?driver ?loc-to)
           (increase (walked) (time-to-walk ?loc-from ?loc-to)))
  )
)
