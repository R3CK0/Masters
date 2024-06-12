(define (domain driverlog)
  (:requirements :typing :durative-actions) 
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

  (:durative-action LOADING
    :parameters (?obj - obj ?v - truck ?loc - location)
    :duration (= ?duration 2)
    :condition
      (and (at start (at ?obj ?loc))
           (at start (at ?v ?loc))
           (at start (empty ?v)))
    :effect
      (and 
        (at start (not (at ?obj ?loc)))
        (at end (in ?obj ?v))
        (at end (not (empty ?v)))
      )
  )

  (:durative-action UNLOADING
    :parameters (?obj - obj ?v - truck ?loc - location)
    :duration (= ?duration 2)
    :condition
      (and (at start (in ?obj ?v))
           (at start (at ?v ?loc)))
    :effect
      (and 
        (at start (not (in ?obj ?v)))
        (at end (at ?obj ?loc))
        (at end (empty ?v))
      )
  )

  (:durative-action BOARDING
    :parameters (?driver - driver ?v - truck ?loc - location)
    :duration (= ?duration 1)
    :condition
      (and (at start (at ?driver ?loc))
           (at start (at ?v ?loc)))
    :effect
      (and 
        (at start (not (at ?driver ?loc)))
        (at end (driving ?driver ?v))
      )
  )

  (:durative-action DISEMBARKING
    :parameters (?driver - driver ?v - truck ?loc - location)
    :duration (= ?duration 1)
    :condition
      (at start (driving ?driver ?v))
    :effect
      (and 
        (at start (not (driving ?driver ?v)))
        (at end (at ?driver ?loc))
      )
  )

  (:durative-action DRIVING
    :parameters (?driver - driver ?v - truck ?loc-from ?loc-to - location)
    :duration (= ?duration 10)
    :condition
      (and (at start (driving ?driver ?v))
           (at start (at ?v ?loc-from))
           (at start (link ?loc-from ?loc-to)))
    :effect
      (and 
        (at start (not (at ?v ?loc-from)))
        (at end (at ?v ?loc-to))
      )
  )

  (:durative-action WALKING
    :parameters (?driver - driver ?loc-from ?loc-to - location)
    :duration (= ?duration 20)
    :condition
      (and (at start (at ?driver ?loc-from))
           (at start (path ?loc-from ?loc-to)))
    :effect
      (and (at start (not (at ?driver ?loc-from)))
           (at end (at ?driver ?loc-to)))
  )
)
