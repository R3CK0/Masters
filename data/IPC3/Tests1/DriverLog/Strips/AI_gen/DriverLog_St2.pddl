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

  ;; Action to load an object into a truck
  (:action LOAD-TRUCK
    :parameters
      (?obj - obj
       ?truck - truck
       ?loc - location)
    :precondition
      (and (at ?truck ?loc) (at ?obj ?loc))
    :effect
      (and 
       (not (at ?obj ?loc)) 
       (in ?obj ?truck)
      )
  )

  ;; Action to unload an object from a truck
  (:action UNLOAD-TRUCK
    :parameters
      (?obj - obj
       ?truck - truck
       ?loc - location)
    :precondition
      (and (at ?truck ?loc) (in ?obj ?truck))
    :effect
      (and 
       (not (in ?obj ?truck)) 
       (at ?obj ?loc)
      )
  )

  ;; Existing action: Walk from one location to another
  (:action WALK
    :parameters
      (?driver - driver
       ?loc-from - location
       ?loc-to - location)
    :precondition
      (and (at ?driver ?loc-from) (path ?loc-from ?loc-to))
    :effect
      (and 
       (not (at ?driver ?loc-from)) 
       (at ?driver ?loc-to)
      )
  )
)
