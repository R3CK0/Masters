(define (domain driverlog)
  (:requirements :typing :durative-actions :fluents) 
  (:types 
    location locatable - object
    driver truck obj - locatable)
  (:predicates 
    (at ?obj - locatable ?loc - location)
    (in ?obj1 - obj ?obj - truck)
    (driving ?d - driver ?v - truck)
    (link ?x ?y - location) 
    (path ?x ?y - location)
    (empty ?v - truck)
  )

  (:functions 
    (time-to-walk ?loc ?loc1 - location)
    (time-to-drive ?loc ?loc1 - location)
  )

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
      (at end (at ?driver ?loc-to)))
  )
  
  (:durative-action BOARD-TRUCK
    :parameters
      (?driver - driver ?truck - truck ?location - location)
    :duration (= ?duration 1)
    :condition
      (and (at start (at ?driver ?location))
           (at start (at ?truck ?location))
           (at start (empty ?truck)))
    :effect
      (and (at start (not (empty ?truck)))
           (at start (not (at ?driver ?location)))
           (at end (driving ?driver ?truck)))
  )

  (:durative-action DISEMBARK-TRUCK
    :parameters
      (?driver - driver ?truck - truck ?location - location)
    :duration (= ?duration 1)
    :condition
      (and (at start (driving ?driver ?truck))
           (at start (at ?truck ?location)))
    :effect
      (and (at start (not (driving ?driver ?truck)))
           (at end (at ?driver ?location))
           (at end (empty ?truck)))
  )

  (:durative-action LOAD-TRUCK
    :parameters
      (?obj - obj ?truck - truck ?location - location)
    :duration (= ?duration 2)
    :condition
      (and (at start (at ?obj ?location))
           (at start (at ?truck ?location)))
    :effect
      (and (at start (not (at ?obj ?location)))
           (at end (in ?obj ?truck)))
  )

  (:durative-action UNLOAD-TRUCK
    :parameters
      (?obj - obj ?truck - truck ?location - location)
    :duration (= ?duration 2)
    :condition
      (and (at start (at ?truck ?location))
           (at start (in ?obj ?truck)))
    :effect
      (and (at start (not (in ?obj ?truck)))
           (at end (at ?obj ?location)))
  )
)
