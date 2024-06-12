(define (domain driverlog)
  (:requirements :typing :durative-actions) 
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
  
  ;; Define BOARD-TRUCK action
  (:durative-action BOARD-TRUCK
    :parameters
     (?driver - driver 
      ?truck - truck 
      ?location - location)
    :duration (= ?duration 1)
    :condition
     (and
       (at start (at ?driver ?location))
       (at start (at ?truck ?location))
       (at start (empty ?truck)))
    :effect
     (and
       (at end (driving ?driver ?truck))
       (at end (not (empty ?truck)))
       (at end (not (at ?driver ?location)))))
  
  ;; Define DISEMBARK-TRUCK action
  (:durative-action DISEMBARK-TRUCK
    :parameters
     (?driver - driver 
      ?truck - truck 
      ?location - location)
    :duration (= ?duration 1)
    :condition
     (and
       (at start (driving ?driver ?truck))
       (at start (at ?truck ?location)))
    :effect
     (and
       (at end (at ?driver ?location))
       (at end (not (driving ?driver ?truck)))
       (at end (empty ?truck))))
  
  ;; Define DRIVE-TRUCK action
  (:durative-action DRIVE-TRUCK
    :parameters
     (?truck - truck
      ?loc-from - location
      ?loc-to - location
      ?driver - driver)
    :duration (= ?duration 10)
    :condition
     (and
       (at start (at ?truck ?loc-from))
       (over all (driving ?driver ?truck))
       (at start (link ?loc-from ?loc-to)))
    :effect
     (and
       (at start (not (at ?truck ?loc-from)))
       (at end (at ?truck ?loc-to))))
  
  ;; Existing WALK action
  (:durative-action WALK
    :parameters
     (?driver - driver
      ?loc-from - location
      ?loc-to - location)
    :duration (= ?duration 20)
    :condition
     (and
       (at start (at ?driver ?loc-from)) 
       (at start (path ?loc-from ?loc-to)))
    :effect
     (and
       (at start (not (at ?driver ?loc-from)))
       (at end (at ?driver ?loc-to))))
)
