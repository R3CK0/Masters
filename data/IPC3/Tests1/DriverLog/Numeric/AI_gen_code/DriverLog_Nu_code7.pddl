(define (domain driverlog)
  (:requirements :typing :fluents) 
  (:types location locatable - object
          driver truck obj - locatable)

  (:predicates 
      (at ?obj - locatable ?loc - location)
      (in ?obj1 - obj ?obj - truck)
      (driving ?d - driver ?v - truck)
      (link ?x ?y - location)
      (path ?x ?y - location)
      (empty ?v - truck)
  )

  (:functions (time-to-walk ?l1 ?l2 - location)
              (time-to-drive ?l1 ?l2 - location)
              (driven)
              (speed ?tr - truck)
              (walked))

  (:action LOAD-TRUCK
    :parameters
     (?obj - obj
      ?truck - truck
      ?loc - location)
    :precondition
     (and (at ?truck ?loc) (at ?obj ?loc))
    :effect
     (and (not (at ?obj ?loc)) (in ?obj ?truck) 
          (assign (at ?obj) nil)))

  (:action UNLOAD-TRUCK
    :parameters
     (?obj - obj
      ?truck - truck
      ?loc - location)
    :precondition
     (and (at ?truck ?loc) (in ?obj ?truck))
    :effect
     (and (not (in ?obj ?truck)) (at ?obj ?loc) 
          (assign (in ?obj) nil)))

  (:action BOARD-TRUCK
    :parameters
     (?driver - driver
      ?truck - truck
      ?loc - location)
    :precondition
     (and (at ?driver ?loc) (at ?truck ?loc) (empty ?truck))
    :effect
     (and (not (at ?driver ?loc)) (driving ?driver ?truck) 
          (not (empty ?truck)) 
          (assign (at ?driver) nil)))

  (:action DISEMBARK-TRUCK
    :parameters
     (?driver - driver
      ?truck - truck
      ?loc - location)
    :precondition
     (and (driving ?driver ?truck) (at ?truck ?loc))
    :effect
     (and (not (driving ?driver ?truck)) (at ?driver ?loc) 
          (empty ?truck) 
          (assign (driving ?driver) nil)))

  (:action DRIVE-TRUCK
    :parameters
     (?truck - truck
      ?loc-from - location
      ?loc-to - location
      ?driver - driver)
    :precondition
     (and (driving ?driver ?truck) (at ?truck ?loc-from) 
          (link ?loc-from ?loc-to))
    :effect
     (and (not (at ?truck ?loc-from)) (at ?truck ?loc-to)
          (increase (driven) 
                    (time-to-drive ?loc-from ?loc-to))))

  (:action WALK
    :parameters
     (?driver - driver
      ?loc-from - location
      ?loc-to - location)
    :precondition
     (and (at ?driver ?loc-from) (path ?loc-from ?loc-to))
    :effect
     (and (not (at ?driver ?loc-from)) (at ?driver ?loc-to)
          (increase (walked) 
                    (time-to-walk ?loc-from ?loc-to))))

  (:action INCREASE-SPEED
    :parameters (?truck - truck ?driver - driver)
    :precondition (and (driving ?driver ?truck) (<= (speed ?truck) 10))
    :effect (increase (speed ?truck) 1))

  (:action DECREASE-SPEED
    :parameters (?truck - truck ?driver - driver)
    :precondition (and (driving ?driver ?truck) (>= (speed ?truck) 1))
    :effect (decrease (speed ?truck) 1))
)
