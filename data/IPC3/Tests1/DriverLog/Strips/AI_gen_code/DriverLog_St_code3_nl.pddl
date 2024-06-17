(define (domain driverlog)
  (:requirements :typing) 
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
    ;; Removed "sober" keeping the prompt requirements
    ;; Removed "tires-ok"
  )

  ;; DRIVE-TRUCK Action
  (:action DRIVE-TRUCK
    :parameters
      (?truck - truck ?loc-from - location ?loc-to - location ?driver - driver)
    :precondition
      (and (at ?truck ?loc-from) (driving ?driver ?truck) (link ?loc-from ?loc-to))
    :effect
      (and (not (at ?truck ?loc-from)) (at ?truck ?loc-to))
  )

  ;; WALK Action
  (:action WALK
    :parameters
      (?driver - driver ?loc-from - location ?loc-to - location)
    :precondition
      (and (at ?driver ?loc-from) (path ?loc-from ?loc-to))
    :effect
      (and (not (at ?driver ?loc-from)) (at ?driver ?loc-to))
  )

  ;; BOARD-TRUCK Action
  (:action BOARD-TRUCK
    :parameters
      (?driver - driver ?truck - truck ?location - location)
    :precondition
      (and (at ?driver ?location) (at ?truck ?location) (empty ?truck))
    :effect
      (and (driving ?driver ?truck) (not (empty ?truck)) (not (at ?driver ?location)))
  )

  ;; DISEMBARK-TRUCK Action
  (:action DISEMBARK-TRUCK
    :parameters
      (?driver - driver ?truck - truck ?location - location)
    :precondition
      (and (driving ?driver ?truck) (at ?truck ?location))
    :effect
      (and (not (driving ?driver ?truck)) (empty ?truck) (at ?driver ?location))
  )

  ;; LOAD-TRUCK Action
  (:action LOAD-TRUCK
    :parameters
      (?obj - obj ?truck - truck ?location - location)
    :precondition
      (and (at ?obj ?location) (at ?truck ?location))
    :effect
      (and (in ?obj ?truck) (not (at ?obj ?location)))
  )

  ;; UNLOAD-TRUCK Action
  (:action UNLOAD-TRUCK
    :parameters
      (?obj - obj ?truck - truck ?location - location)
    :precondition
      (and (in ?obj ?truck) (at ?truck ?location))
    :effect
      (and (not (in ?obj ?truck)) (at ?obj ?location))
  )
  ;; Removed INFLATE-TIRES action
)
