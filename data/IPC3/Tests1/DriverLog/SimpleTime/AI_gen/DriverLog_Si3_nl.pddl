(define (domain driverlog)
  (:requirements :typing :durative-actions)
  (:types location locatable - object driver truck obj - locatable)

  (:predicates 
    (at ?obj - locatable ?loc - location)
    (in ?obj1 - obj ?obj - truck)
    (driving ?d - driver ?v - truck)
    (link ?x ?y - location) 
    (path ?x ?y - location)
    (empty ?v - truck)
  )

  (:durative-action DRIVE-TRUCK
    :parameters (?truck - truck ?loc-from - location ?loc-to - location ?driver - driver)
    :duration (= ?duration 10)
    :condition 
      (and (at start (at ?truck ?loc-from))
           (over all (driving ?driver ?truck))
           (at start (link ?loc-from ?loc-to)))
    :effect
      (and (at start (not (at ?truck ?loc-from)))
           (at end (at ?truck ?loc-to)))
  )

  (:durative-action WALK
    :parameters (?driver - driver ?loc-from - location ?loc-to - location)
    :duration (= ?duration 20)
    :condition 
      (and (at start (at ?driver ?loc-from))
           (at start (path ?loc-from ?loc-to)))
    :effect
      (and (at start (not (at ?driver ?loc-from)))
           (at end (at ?driver ?loc-to)))
  )

  (:durative-action BOARD-TRUCK
    :parameters (?driver - driver ?truck - truck ?loc - location)
    :duration (= ?duration 1)
    :condition 
      (and (at start (at ?truck ?loc))
           (at start (at ?driver ?loc))
           (at start (empty ?truck)))
    :effect
      (and (at start (empty ?truck))
           (over all (driving ?driver ?truck)))))
  )

  (:durative-action DISEMBARK-TRUCK
    :parameters (?driver - driver ?truck - truck ?loc - location)
    :duration (= ?duration 1)
    :condition 
      (and (at start (at ?truck ?loc))
           (over all (driving ?driver ?truck)))
    :effect
      (and (at end (at ?driver ?loc))
           (at end (empty ?truck))
           (at end (not (driving ?driver ?truck))))
  )

  (:durative-action LOAD-TRUCK
    :parameters (?obj - obj ?truck - truck ?loc - location)
    :duration (= ?duration 2)
    :condition 
      (and (at start (at ?obj ?loc))
           (at start (at ?truck ?loc)))
    :effect 
      (and (at start (not (at ?obj ?loc)))
           (at end (in ?obj ?truck))))
  )

  (:durative-action UNLOAD-TRUCK
    :parameters (?obj - obj ?truck - truck ?loc - location)
    :duration (= ?duration 2)
    :condition 
      (and (at start (in ?obj ?truck))
           (at start (at ?truck ?loc)))
    :effect 
      (and (at start (not (in ?obj ?truck)))
           (at end (at ?obj ?loc))))
  )
)
