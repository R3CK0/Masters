(define (domain driverlog)
  (:requirements :typing) 
  (:types
    location locatable - object
    driver truck obj - locatable)
  
  (:predicates 
    (at ?locatable - locatable ?loc - location)
    (in ?obj - obj ?truck - truck)
    (driving ?driver - driver ?truck - truck)
    (link ?loc1 ?loc2 - location)
    (path ?loc1 ?loc2 - location)
    (empty ?truck - truck)
    (sober ?driver - driver))

  (:action LOAD-TRUCK
    :parameters (?obj - obj ?truck - truck ?loc - location)
    :precondition (and (at ?truck ?loc) (at ?obj ?loc))
    :effect (and (not (at ?obj ?loc)) (in ?obj ?truck)))

  (:action UNLOAD-TRUCK
    :parameters (?obj - obj ?truck - truck ?loc - location)
    :precondition (and (at ?truck ?loc) (in ?obj ?truck))
    :effect (and (not (in ?obj ?truck)) (at ?obj ?loc)))

  (:action BOARD-TRUCK
    :parameters (?driver - driver ?truck - truck ?loc - location)
    :precondition (and (at ?truck ?loc) (at ?driver ?loc) (empty ?truck))
    :effect (and (not (at ?driver ?loc)) (driving ?driver ?truck) (not (empty ?truck))))

  (:action DISEMBARK-TRUCK
    :parameters (?driver - driver ?truck - truck ?loc - location)
    :precondition (and (at ?truck ?loc) (driving ?driver ?truck))
    :effect (and (not (driving ?driver ?truck)) (at ?driver ?loc) (empty ?truck)))

  (:action DRIVE-TRUCK
    :parameters (?driver - driver ?truck - truck ?loc-from - location ?loc-to - location)
    :precondition (and (at ?truck ?loc-from) (driving ?driver ?truck) (link ?loc-from ?loc-to) (sober ?driver))
    :effect (and (not (at ?truck ?loc-from)) (at ?truck ?loc-to)))

  (:action WALK
    :parameters (?driver - driver ?loc-from - location ?loc-to - location)
    :precondition (and (at ?driver ?loc-from) (path ?loc-from ?loc-to) (sober ?driver))
    :effect (and (not (at ?driver ?loc-from)) (at ?driver ?loc-to)))
)
