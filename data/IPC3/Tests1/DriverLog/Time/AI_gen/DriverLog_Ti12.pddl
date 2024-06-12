(define (domain driverlog)
  (:requirements :typing :durative-actions :fluents) 
  (:types 
          location locatable - object
          driver truck obj - locatable)
  (:predicates 
        (at ?obj - locatable ?loc - location)
        (in ?obj1 - obj ?obj - truck)
        (driving ?d - driver ?v - truck) ; Added driving predicate
        (path ?x ?y - location)           ; Added path predicate
        (link ?x ?y - location)
        (empty ?v - truck)
  )

  (:functions (time-to-walk ?loc ?loc1 - location)
              (time-to-drive ?loc ?loc1 - location))

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
     (and (over all (at ?truck ?loc)) (at start (at ?driver ?loc)) 
          (at start (empty ?truck)))
    :effect
     (and (at start (not (at ?driver ?loc))) 
          (at end (driving ?driver ?truck)) ; Modified to indicate driver is now driving
          (at start (not (empty ?truck)))))

  (:durative-action DISEMBARK-TRUCK
    :parameters
     (?driver - driver
      ?truck - truck
      ?loc - location)
    :duration (= ?duration 1)
    :condition
     (and (over all (at ?truck ?loc)) (at start (driving ?driver ?truck))) ; Driver is driving at start
    :effect
     (and (at start (not (driving ?driver ?truck)))  ; Modified to indicate driver is no longer driving
          (at end (at ?driver ?loc)) 
          (at end (empty ?truck))))

  (:durative-action DRIVE-TRUCK
    :parameters
     (?truck - truck
      ?loc-from - location
      ?loc-to - location
      ?driver - driver)
    :duration (= ?duration (time-to-drive ?loc-from ?loc-to))
    :condition
     (and (at start (at ?truck ?loc-from))
          (over all (driving ?driver ?truck)) ; Driver must be driving the truck
          (at start (link ?loc-from ?loc-to)))
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
          (at start (path ?loc-from ?loc-to))) ; Path must exist between the locations
    :effect
     (and (at start (not (at ?driver ?loc-from)))
          (at end (at ?driver ?loc-to))))
)
