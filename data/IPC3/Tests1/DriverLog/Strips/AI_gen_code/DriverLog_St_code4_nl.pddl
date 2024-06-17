(define (domain driverlog)
  (:requirements :typing)
  (:types location locatable - object
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
      (?driver - driver
       ?truck - truck
       ?loc - location)
    :precondition
      (and (at ?driver ?loc) (at ?truck ?loc) (empty ?truck))
    :effect
      (and (not (at ?driver ?loc))
           (driving ?driver ?truck)
           (not (empty ?truck))))

  (:action DISEMBARK-TRUCK
    :parameters
      (?driver - driver
       ?truck - truck
       ?loc - location)
    :precondition
      (and (driving ?driver ?truck) (at ?truck ?loc))
    :effect
      (and (not (driving ?driver ?truck))
           (at ?driver ?loc)
           (empty ?truck)))

  (:action LOAD-TRUCK
    :parameters
      (?obj - obj
       ?truck - truck
       ?loc - location)
    :precondition
      (and (at ?obj ?loc) (at ?truck ?loc))
    :effect
      (and (not (at ?obj ?loc))
           (in ?obj ?truck)))

  (:action UNLOAD-TRUCK
    :parameters
      (?obj - obj
       ?truck - truck
       ?loc - location)
    :precondition
      (and (in ?obj ?truck) (at ?truck ?loc))
    :effect
      (and (not (in ?obj ?truck))
           (at ?obj ?loc)))

  (:action DRIVE-TRUCK
    :parameters
      (?driver - driver
       ?truck - truck
       ?loc-from - location
       ?loc-to - location)
    :precondition
      (and (driving ?driver ?truck) (at ?truck ?loc-from) (link ?loc-from ?loc-to))
    :effect
      (and (not (at ?truck ?loc-from))
           (at ?truck ?loc-to)))
)
