(define (domain driverlog)
  (:requirements :typing :durative-actions :fluents)
  (:types 
    location locatable - object
    driver truck obj - locatable)
  (:predicates 
    (at ?obj - locatable ?loc - location)
    (in ?obj1 - obj ?obj - truck)
    (link ?x ?y - location) ; Represents a drivable path between two locations
    (path ?x ?y - location) ; Represents a walkable path between two locations
    (empty ?v - truck)      ; Indicates if a truck has no driver inside
    (driving ?driver - driver ?truck - truck)) ; Indicates if a driver is driving a truck
  
  (:functions 
    (time-to-walk ?loc ?loc1 - location) ; Duration to walk between locations
    (time-to-drive ?loc ?loc1 - location)) ; Duration to drive between locations
  
  (:durative-action LOAD-TRUCK
    :parameters
      (?obj - obj
       ?truck - truck
       ?loc - location)
    :duration (= ?duration 2)
    :condition
      (and (over all (at ?truck ?loc)) (at start (at ?obj ?loc)))
    :effect
      (and (at start (not (at ?obj ?loc))) (at end (in ?obj ?truck))))
  
  (:durative-action UNLOAD-TRUCK
    :parameters
      (?obj - obj 
       ?truck - truck
       ?loc - location)
    :duration (= ?duration 2)
    :condition
      (and (over all (at ?truck ?loc)) (at start (in ?obj ?truck)))
    :effect
      (and (at start (not (in ?obj ?truck))) (at end (at ?obj ?loc))))
  
  (:durative-action BOARD-TRUCK
    :parameters
      (?driver - driver
       ?truck - truck
       ?loc - location)
    :duration (= ?duration 1)
    :condition
      (and (over all (at ?truck ?loc)) (at start (at ?driver ?loc)) (at start (empty ?truck)))
    :effect
      (and (at start (not (at ?driver ?loc))) (at start (not (empty ?truck))) (at end (driving ?driver ?truck))))
  
  (:durative-action DISEMBARK-TRUCK
    :parameters
      (?driver - driver
       ?truck - truck
       ?loc - location)
    :duration (= ?duration 1)
    :condition
      (and (over all (at ?truck ?loc)) (at start (driving ?driver ?truck)))
    :effect
      (and (at end (at ?driver ?loc)) (at end (empty ?truck)) (at start (not (driving ?driver ?truck)))))
  
  (:durative-action DRIVE-TRUCK
    :parameters
      (?truck - truck
       ?loc-from - location
       ?loc-to - location
       ?driver - driver)
    :duration (= ?duration (time-to-drive ?loc-from ?loc-to))
    :condition
      (and (at start (at ?truck ?loc-from)) (at start (link ?loc-from ?loc-to)) (over all (driving ?driver ?truck)))
    :effect
      (and (at start (not (at ?truck ?loc-from))) (at end (at ?truck ?loc-to))))
  
  (:durative-action WALK
    :parameters
      (?driver - driver
       ?loc-from - location
       ?loc-to - location)
    :duration (= ?duration (time-to-walk ?loc-from ?loc-to))
    :condition
      (and (at start (at ?driver ?loc-from)) (at start (path ?loc-from ?loc-to)))
    :effect
      (and (at start (not (at ?driver ?loc-from))) (at end (at ?driver ?loc-to))))
)

