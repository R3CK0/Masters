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
    (empty ?v - truck))
  
  (:functions 
    (time-to-walk ?loc ?loc1 - location)
    (time-to-drive ?loc ?loc1 - location))
  
  ;; Action that moves an object into the truck
  (:durative-action LOAD-TRUCK
    :parameters
    (?obj - obj
      ?truck - truck
      ?loc - location)
    :duration (= ?duration 2)
    :condition
    (and 
      (over all (at ?truck ?loc)) ;; Truck needs to be at the location for the entire duration
      (at start (at ?obj ?loc)))  ;; Object needs to be at the location at the start of the action
    :effect
    (and 
      (at start (not (at ?obj ?loc))) ;; Object is no longer at the location at the start
      (at end (in ?obj ?truck)))) ;; Object is in the truck at the end

  ;; Action that moves an object out of the truck
  (:durative-action UNLOAD-TRUCK
    :parameters
    (?obj - obj 
      ?truck - truck
      ?loc - location)
    :duration (= ?duration 2)
    :condition
    (and 
      (over all (at ?truck ?loc)) ;; Truck needs to be at the location for the entire duration
      (at start (in ?obj ?truck))) ;; Object needs to be in the truck at the start of the action
    :effect
    (and 
      (at start (not (in ?obj ?truck))) ;; Object is no longer in the truck at the start
      (at end (at ?obj ?loc)))) ;; Object is at the location at the end

  ;; Walking action for the driver
  (:durative-action WALK
    :parameters
    (?driver - driver
      ?loc-from - location
      ?loc-to - location)
    :duration (= ?duration (time-to-walk ?loc-from ?loc-to))
    :condition
    (and 
      (at start (at ?driver ?loc-from)) 
      (at start (path ?loc-from ?loc-to)))
    :effect
    (and 
      (at start (not (at ?driver ?loc-from)))
      (at end (at ?driver ?loc-to))))
)

