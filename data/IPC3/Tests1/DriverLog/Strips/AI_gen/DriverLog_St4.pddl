(define (domain driverlog)
  (:requirements :typing) 
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

(:action WALK
  :parameters
   (?driver - driver
    ?loc-from - location
    ?loc-to - location)
  :precondition
   (and (at ?driver ?loc-from) (path ?loc-from ?loc-to))
  :effect
   (and (not (at ?driver ?loc-from)) (at ?driver ?loc-to)))

(:action BOARD-TRUCK
  :parameters
    (?driver - driver ?truck - truck ?location - location)
  :precondition
    (and (at ?driver ?location) (at ?truck ?location) (empty ?truck))
  :effect
    (and (not (at ?driver ?location)) (driving ?driver ?truck) (not (empty ?truck))))

(:action DISEMBARK-TRUCK
  :parameters
    (?driver - driver ?truck - truck ?location - location)
  :precondition
    (and (at ?truck ?location) (driving ?driver ?truck))
  :effect
    (and (not (driving ?driver ?truck)) (at ?driver ?location) (empty ?truck)))

(:action LOAD-TRUCK
  :parameters
    (?obj - obj ?truck - truck ?location - location)
  :precondition
    (and (at ?obj ?location) (at ?truck ?location))
  :effect
    (and (not (at ?obj ?location)) (in ?obj ?truck)))

(:action UNLOAD-TRUCK
  :parameters
    (?obj - obj ?truck - truck ?location - location)
  :precondition
    (and (at ?truck ?location) (in ?obj ?truck))
  :effect
    (and (not (in ?obj ?truck)) (at ?obj ?location)))
)
