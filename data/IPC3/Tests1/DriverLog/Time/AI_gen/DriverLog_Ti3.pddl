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

  (:durative-action BOARD-TRUCK
    :parameters
     (?driver - driver
      ?truck - truck
      ?loc - location)
    :duration (= ?duration 1)
    :condition
     (and (at start (at ?truck ?loc))
          (at start (at ?driver ?loc))
          (at start (empty ?truck)))
    :effect
     (and (at start (not (empty ?truck)))
          (at start (not (at ?driver ?loc)))
          (at end (driving ?driver ?truck))))

  (:durative-action DISEMBARK-TRUCK
    :parameters
     (?driver - driver
      ?truck - truck
      ?loc - location)
    :duration (= ?duration 1)
    :condition
     (and (at start (at ?truck ?loc))
          (over all (driving ?driver ?truck)))
    :effect
     (and (at start (not (driving ?driver ?truck)))
          (at end (at ?driver ?loc))
          (at end (empty ?truck))))
)
