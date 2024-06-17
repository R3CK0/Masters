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
           (at ?truck ?loc-to)))
  
  (:action WALK
    :parameters
      (?driver - driver
       ?loc-from - location
       ?loc-to - location)
    :precondition
      (and (at ?driver ?loc-from)
           (path ?loc-from ?loc-to))
    :effect
      (and (not (at ?driver ?loc-from))
           (at ?driver ?loc-to)))

  (:action LOAD-TRUCK
    :parameters
      (?obj - obj
       ?truck - truck
       ?loc - location)
    :precondition
      (and (at ?truck ?loc)
           (at ?obj ?loc))
    :effect
      (and (not (at ?obj ?loc))
           (in ?obj ?truck)))

  (:action UNLOAD-TRUCK
    :parameters
      (?obj - obj
       ?truck - truck
       ?loc - location)
    :precondition
      (and (at ?truck ?loc)
           (in ?obj ?truck))
    :effect
      (and (at ?obj ?loc)
           (not (in ?obj ?truck))))

  (:action BOARD-TRUCK
    :parameters
      (?driver - driver
       ?truck - truck
       ?loc - location)
    :precondition
      (and (at ?driver ?loc)
           (empty ?truck)
           (at ?truck ?loc))
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
      (and (driving ?driver ?truck)
           (at ?truck ?loc))
    :effect
      (and (at ?driver ?loc)
           (not (driving ?driver ?truck))
           (empty ?truck)))

)
