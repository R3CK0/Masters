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
  )

  ;; Action for boarding the truck
  (:action BOARD-TRUCK
    :parameters (?d - driver ?t - truck ?loc - location)
    :precondition (and (at ?d ?loc) (at ?t ?loc) (empty ?t))
    :effect (and (not (at ?d ?loc)) (driving ?d ?t) (not (empty ?t))))

  ;; Action for disembarking the truck
  (:action DISEMBARK-TRUCK
    :parameters (?d - driver ?t - truck ?loc - location)
    :precondition (and (driving ?d ?t) (at ?t ?loc))
    :effect (and (not (driving ?d ?t)) (at ?d ?loc) (empty ?t)))
  
  ;; Action for loading an object into the truck
  (:action LOAD-TRUCK
    :parameters (?obj - obj ?truck - truck ?loc - location)
    :precondition (and (at ?truck ?loc) (at ?obj ?loc))
    :effect (and (not (at ?obj ?loc)) (in ?obj ?truck)))
  
  ;; Action for unloading an object from the truck
  (:action UNLOAD-TRUCK
    :parameters (?obj - obj ?truck - truck ?loc - location)
    :precondition (and (at ?truck ?loc) (in ?obj ?truck))
    :effect (and (not (in ?obj ?truck)) (at ?obj ?loc)))

  ;; Action for walking from one location to another
  (:action WALK
    :parameters (?driver - driver ?loc-from - location ?loc-to - location)
    :precondition (and (at ?driver ?loc-from) (path ?loc-from ?loc-to))
    :effect (and (not (at ?driver ?loc-from)) (at ?driver ?loc-to)))
)
