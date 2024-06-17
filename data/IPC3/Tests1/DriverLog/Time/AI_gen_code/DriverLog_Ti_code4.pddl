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

  (:durative-action WALK
    :parameters (?driver - driver ?loc-from - location ?loc-to - location)
    :duration (= ?duration (time-to-walk ?loc-from ?loc-to))
    :condition (and (at start (at ?driver ?loc-from)) 
                    (at start (path ?loc-from ?loc-to)))
    :effect (and (at start (not (at ?driver ?loc-from)))
                 (at end (at ?driver ?loc-to)))
  )

  (:action LOAD_TRUCK
    :parameters (?obj - obj ?truck - truck ?location - location)
    :precondition (and (at ?truck ?location)
                       (at ?obj ?location))
    :effect (and (not (at ?obj ?location))
                 (in ?obj ?truck))
  )

  (:action UNLOAD_TRUCK
    :parameters (?obj - obj ?truck - truck ?location - location)
    :precondition (and (at ?truck ?location)
                       (in ?obj ?truck))
    :effect (and (not (in ?obj ?truck))
                 (at ?obj ?location))
  )

  (:action BOARD_TRUCK
    :parameters (?driver - driver ?truck - truck ?location - location)
    :precondition (and (at ?driver ?location)
                       (at ?truck ?location)
                       (empty ?truck))
    :effect (and (not (at ?driver ?location))
                 (driving ?driver ?truck)
                 (not (empty ?truck)))
  )

  (:action DISEMBARK_TRUCK
    :parameters (?driver - driver ?truck - truck ?location - location)
    :precondition (and (driving ?driver ?truck)
                       (at ?truck ?location))
    :effect (and (not (driving ?driver ?truck))
                 (at ?driver ?location)
                 (empty ?truck))
  )

  (:durative-action DRIVE_TRUCK
    :parameters (?driver - driver ?truck - truck ?loc-from - location ?loc-to - location)
    :duration (= ?duration (time-to-drive ?loc-from ?loc-to))
    :condition (and (at start (driving ?driver ?truck))
                    (at start (at ?truck ?loc-from))
                    (at start (link ?loc-from ?loc-to)))
    :effect (and (at start (not (at ?truck ?loc-from)))
                 (at end (at ?truck ?loc-to)))
  )
)
