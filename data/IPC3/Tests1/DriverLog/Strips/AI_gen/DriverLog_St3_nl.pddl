(define (domain driverlog)
  (:requirements :typing) 
  (:types
    location locatable - object
    driver truck obj - locatable
  )
  (:predicates
    (at ?obj - locatable ?loc - location)
    (in ?obj - obj ?truck - truck)
    (driving ?d - driver ?v - truck)
    (link ?x ?y - location)
    (path ?x ?y - location)
    (empty ?v - truck)
    (boarded ?driver - driver ?truck - truck)
  )

  ;; Driver boards the truck
  (:action BOARD-TRUCK
    :parameters
      (?driver - driver ?truck - truck ?loc - location)
    :precondition
      (and (at ?driver ?loc)
           (at ?truck ?loc)
           (empty ?truck))
    :effect
      (and (not (empty ?truck))
           (boarded ?driver ?truck))
  )

  ;; Driver disembarks from the truck
  (:action DISEMBARK-TRUCK
    :parameters
      (?driver - driver ?truck - truck ?loc - location)
    :precondition
      (and (at ?truck ?loc)
           (boarded ?driver ?truck))
    :effect
      (and (empty ?truck)
           (not (boarded ?driver ?truck)))
  )

  ;; Load an object into the truck
  (:action LOAD-TRUCK
    :parameters
      (?obj - obj ?truck - truck ?loc - location)
    :precondition
      (and (at ?obj ?loc)
           (at ?truck ?loc))
    :effect
      (and (not (at ?obj ?loc))
           (in ?obj ?truck))
  )

  ;; Unload an object from the truck
  (:action UNLOAD-TRUCK
    :parameters
      (?obj - obj ?truck - truck ?loc - location)
    :precondition
      (and (in ?obj ?truck)
           (at ?truck ?loc))
    :effect
      (and (not (in ?obj ?truck))
           (at ?obj ?loc))
  )
  
  ;; Drive the truck from one location to another
  (:action DRIVE-TRUCK
    :parameters
     (?truck - truck ?loc-from - location ?loc-to - location ?driver - driver)
    :precondition
     (and (at ?truck ?loc-from)
          (boarded ?driver ?truck)
          (link ?loc-from ?loc-to))
    :effect
     (and (not (at ?truck ?loc-from))
          (at ?truck ?loc-to))
  )

  ;; Driver walks from one location to another
  (:action WALK
    :parameters
     (?driver - driver ?loc-from - location ?loc-to - location)
    :precondition
     (and (at ?driver ?loc-from) (path ?loc-from ?loc-to))
    :effect
     (and (not (at ?driver ?loc-from)) (at ?driver ?loc-to)))
)
