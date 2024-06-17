(define (domain driverlog)
  (:requirements :typing :durative-actions) 
  (:types           location locatable - object
    driver truck obj - locatable)

  (:predicates 
    (at ?obj - locatable ?loc - location)
    (in ?obj1 - obj ?obj - truck)
    (link ?x ?y - location)
    (empty ?v - truck)
    (driving ?driver - driver ?truck - truck)
)

(:durative-action LOAD-TRUCK
  :parameters
   (?obj - obj
    ?truck - truck
    ?loc - location)
  :duration (= ?duration 2)
  :condition
   (and 
   (over all (at ?truck ?loc)) 
   (at start (at ?obj ?loc)))
  :effect
   (and 
     (at start (not (at ?obj ?loc))) 
     (at end (in ?obj ?truck))))

(:durative-action UNLOAD-TRUCK
  :parameters
   (?obj - obj
    ?truck - truck
    ?loc - location)
  :duration (= ?duration 2)
  :condition
   (and
        (over all (at ?truck ?loc)) 
        (at start (in ?obj ?truck)))
  :effect
   (and 
     (at start (not (in ?obj ?truck))) 
     (at end (at ?obj ?loc))))

(:durative-action BOARD-TRUCK
  :parameters
   (?driver - driver
    ?truck - truck
    ?loc - location)
  :duration (= ?duration 1)
  :condition
   (and 
   (over all (at ?truck ?loc)) 
   (at start (at ?driver ?loc)) 
   (at start (empty ?truck)))
  :effect
   (and 
     (at start (not (at ?driver ?loc))) 
     (at start (not (empty ?truck)))
     (at end (driving ?driver ?truck))))

(:durative-action DISEMBARK-TRUCK
  :parameters
   (?driver - driver
    ?truck - truck
    ?loc - location)
  :duration (= ?duration 1)
  :condition
   (and 
     (over all (driving ?driver ?truck)) 
     (over all (at ?truck ?loc)))
  :effect
   (and 
     (at end (at ?driver ?loc)) 
     (at end (empty ?truck)) 
     (at end (not (driving ?driver ?truck)))))

(:durative-action DRIVE-TRUCK
  :parameters
   (?truck - truck
    ?loc-from - location
    ?loc-to - location
    ?driver - driver)
  :duration (= ?duration 10)
  :condition
   (and 
     (at start (driving ?driver ?truck)) 
     (at start (at ?truck ?loc-from))
     (at start (link ?loc-from ?loc-to)))
  :effect
   (and 
     (at start (not (at ?truck ?loc-from))) 
     (at end (at ?truck ?loc-to))))

(:durative-action WALK
  :parameters
   (?driver - driver
    ?loc-from - location
    ?loc-to - location)
  :duration (= ?duration 20)
  :condition
   (and 
     (at start (at ?driver ?loc-from))
     (at start (link ?loc-from ?loc-to)))  
  :effect
   (and 
     (at start (not (at ?driver ?loc-from)))
     (at end (at ?driver ?loc-to))))
)