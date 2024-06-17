(define (domain driverlog)
  (:requirements :typing :fluents) 
  (:types
    location locatable - object
    driver truck obj - locatable)

  (:predicates 
    (at ?obj - locatable ?loc - location)
    (in ?obj - obj ?truck - truck)
    (driving ?d - driver ?truck - truck)
    (link ?loc-from ?loc-to - location) 
    (path ?loc-from ?loc-to - location)
    (empty ?truck - truck)
    (tires-ok ?truck - truck)
    (sober ?driver - driver)
  )

  (:functions
    (time-to-walk ?loc-from ?loc-to - location)
    (time-to-drive ?loc-from ?loc-to - location)
    (driven)
    (walked)
  )

  (:action LOAD-TRUCK
    :parameters (?obj - obj ?truck - truck ?loc - location)
    :precondition (and (at ?truck ?loc) (at ?obj ?loc))
    :effect (and (not (at ?obj ?loc)) (in ?obj ?truck))
  )

  (:action UNLOAD-TRUCK
    :parameters (?obj - obj ?truck - truck ?loc - location)
    :precondition (and (at ?truck ?loc) (in ?obj ?truck))
    :effect (and (not (in ?obj ?truck)) (at ?obj ?loc))
  )

  (:action BOARD-TRUCK
    :parameters (?driver - driver ?truck - truck ?loc - location)
    :precondition (and (at ?driver ?loc) (at ?truck ?loc) (empty ?truck))
    :effect (and (not (at ?driver ?loc)) (driving ?driver ?truck) (not (empty ?truck)))
  )

  (:action DISEMBARK-TRUCK
    :parameters (?driver - driver ?truck - truck ?loc - location)
    :precondition (and (driving ?driver ?truck) (at ?truck ?loc))
    :effect (and (not (driving ?driver ?truck)) (at ?driver ?loc) (empty ?truck))
  )

  (:action DRIVE-TRUCK
    :parameters (?driver - driver ?truck - truck ?loc-from - location ?loc-to - location)
    :precondition (and (driving ?driver ?truck) (at ?truck ?loc-from) (link ?loc-from ?loc-to) (tires-ok ?truck) (sober ?driver))
    :effect (and (not (at ?truck ?loc-from)) (at ?truck ?loc-to) (increase (driven) (time-to-drive ?loc-from ?loc-to)))
  )

  (:action WALK
    :parameters (?driver - driver ?loc-from - location ?loc-to - location)
    :precondition (and (at ?driver ?loc-from) (path ?loc-from ?loc-to))
    :effect (and (not (at ?driver ?loc-from)) (at ?driver ?loc-to) (increase (walked) (time-to-walk ?loc-from ?loc-to)) (sober ?driver))
  )

  (:action INFLATE-TIRES
    :parameters (?truck - truck)
    :precondition ()
    :effect (tires-ok ?truck)
  )
)
