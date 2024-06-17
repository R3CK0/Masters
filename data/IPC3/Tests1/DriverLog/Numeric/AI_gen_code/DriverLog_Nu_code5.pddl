(define (domain driverlog)
  (:requirements :typing :fluents) 
  (:types           location locatable - object
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
    (walked))

  ;; Load an object into a truck
  (:action LOAD-TRUCK
    :parameters (?obj - obj ?truck - truck ?loc - location)
    :precondition (and (at ?truck ?loc) (at ?obj ?loc))
    :effect (and (not (at ?obj ?loc)) (in ?obj ?truck)))

  ;; Unload an object from a truck
  (:action UNLOAD-TRUCK
    :parameters (?obj - obj ?truck - truck ?loc - location)
    :precondition (and (at ?truck ?loc) (in ?obj ?truck))
    :effect (and (at ?obj ?loc) (not (in ?obj ?truck))))

  ;; Board a truck
  (:action BOARD-TRUCK
    :parameters (?driver - driver ?truck - truck ?loc - location)
    :precondition 
      (and (at ?driver ?loc) (empty ?truck) (at ?truck ?loc))
    :effect
      (and (driving ?driver ?truck) (not (at ?driver ?loc)) (not (empty ?truck))))

  ;; Disembark from a truck
  (:action DISEMBARK-TRUCK
    :parameters (?driver - driver ?truck - truck ?loc - location)
    :precondition (and (driving ?driver ?truck) (at ?truck ?loc))
    :effect (and (not (driving ?driver ?truck)) (at ?driver ?loc) (empty ?truck)))

  ;; Drive the truck from one location to another
  (:action DRIVE-TRUCK
    :parameters
     (?truck - truck ?loc-from - location ?loc-to - location ?driver - driver)
    :precondition
     (and (at ?truck ?loc-from) (driving ?driver ?truck) (link ?loc-from ?loc-to))
    :effect
     (and (not (at ?truck ?loc-from)) (at ?truck ?loc-to)
      (increase (driven) (time-to-drive ?loc-from ?loc-to))))

  ;; Walk from one location to another
  (:action WALK
    :parameters
     (?driver - driver ?loc-from - location ?loc-to - location)
    :precondition
     (and (at ?driver ?loc-from) (path ?loc-from ?loc-to))
    :effect
     (and (not (at ?driver ?loc-from)) (at ?driver ?loc-to)
      (increase (walked) (time-to-walk ?loc-from ?loc-to))))
)
