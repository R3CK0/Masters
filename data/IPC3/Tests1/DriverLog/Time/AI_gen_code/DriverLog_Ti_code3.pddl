(define (domain driverlog)
  (:requirements :typing :durative-actions :fluents) 
  (:types 
          location locatable - object
          driver truck obj - locatable)
  (:predicates 
        (at ?obj - locatable ?loc - location)
        (in ?obj1 - obj ?obj - truck)
        (driving ?d - driver ?v - truck)
        (link ?x ?y - location) (path ?x ?y - location)
        (empty ?v - truck)
)


(:functions (time-to-walk ?loc ?loc1 - location)
            (time-to-drive ?loc ?loc1 - location))

(:durative-action DRIVE-TRUCK
  :parameters
   (?truck - truck
    ?loc-from - location
    ?loc-to - location
    ?driver - driver)
  :duration (= ?duration (time-to-drive ?loc-from ?loc-to))
  :condition
   (and (at start (at ?truck ?loc-from))
   (over all (driving ?driver ?truck)) (at start (link ?loc-from ?loc-to)))
  :effect
   (and (at start (not (at ?truck ?loc-from))) 
        (at end (at ?truck ?loc-to))))

(:durative-action WALK
  :parameters
   (?driver - driver
    ?loc-from - location
    ?loc-to - location)
  :duration (= ?duration (time-to-walk ?loc-from ?loc-to))
  :condition
   (and (at start (at ?driver ?loc-from)) 
        (at start (path ?loc-from ?loc-to)))
  :effect
   (and (at start (not (at ?driver ?loc-from)))
        (at end (at ?driver ?loc-to))))

(:action LOAD-TRUCK
  :parameters
   (?obj - obj
    ?truck - truck
    ?loc - location)
  :precondition
   (and (at ?truck ?loc)
        (at ?obj ?loc))
  :effect
   (and 
        (not (at ?obj ?loc))
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
   (and 
        (not (in ?obj ?truck))
        (at ?obj ?loc)))

(:action BOARD-TRUCK
  :parameters
   (?driver - driver
    ?truck - truck
    ?loc - location)
  :precondition
   (and (at ?driver ?loc)
        (at ?truck ?loc)
        (empty ?truck))
  :effect
   (and 
        (not (at ?driver ?loc))
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
   (and 
        (not (driving ?driver ?truck))
        (at ?driver ?loc)
        (empty ?truck)))
)
