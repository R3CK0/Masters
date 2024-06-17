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
      (link ?x ?y - location) (path ?x ?y - location)
      (empty ?v - truck)
  )

  ;; Load an object onto a truck
  (:action LOAD-TRUCK
    :parameters
     (?obj - obj ?truck - truck ?loc - location)
    :precondition
     (and (at ?truck ?loc) (at ?obj ?loc))
    :effect
     (and (not (at ?obj ?loc)) (in ?obj ?truck))
  )

  ;; Unload an object from a truck
  (:action UNLOAD-TRUCK
    :parameters
     (?obj - obj ?truck - truck ?loc - location)
    :precondition
     (and (at ?truck ?loc) (in ?obj ?truck))
    :effect
     (and (not (in ?obj ?truck)) (at ?obj ?loc))
  )

  ;; Board a driver into a truck
  (:action BOARD-TRUCK
    :parameters
     (?driver - driver ?truck - truck ?loc - location)
    :precondition
     (and (at ?driver ?loc) (at ?truck ?loc) (empty ?truck))
    :effect
     (and (not (at ?driver ?loc)) (driving ?driver ?truck) (not (empty ?truck)))
  )

  ;; Disembark a driver from a truck
  (:action DISEMBARK-TRUCK
    :parameters
     (?driver - driver ?truck - truck ?loc - location)
    :precondition
     (and (driving ?driver ?truck) (at ?truck ?loc))
    :effect
     (and (not (driving ?driver ?truck)) (at ?driver ?loc) (empty ?truck))
  )

  ;; Drive a truck from one location to another
  (:action DRIVE-TRUCK
    :parameters
     (?driver - driver ?truck - truck ?loc-from - location ?loc-to - location)
    :precondition
     (and (driving ?driver ?truck) (at ?truck ?loc-from) (link ?loc-from ?loc-to))
    :effect
     (and (not (at ?truck ?loc-from)) (at ?truck ?loc-to))
  )

  ;; Walk from one location to another
  (:action WALK
    :parameters
     (?driver - driver ?loc-from - location ?loc-to - location)
    :precondition
     (and (at ?driver ?loc-from) (path ?loc-from ?loc-to))
    :effect
     (and (not (at ?driver ?loc-from)) (at ?driver ?loc-to))
  )
)
