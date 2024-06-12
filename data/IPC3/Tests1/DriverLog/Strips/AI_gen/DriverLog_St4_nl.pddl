(define (domain driverlog)
  (:requirements :typing)
  
  (:types
    location locatable - object
    driver truck obj - locatable
  )
  
  (:predicates
    (at ?obj - locatable ?loc - location)
    (in ?obj1 - obj ?obj - truck)
    (driving ?d - driver ?v - truck) ;; New predicate added
    (link ?x ?y - location)
    (path ?x ?y - location) ;; New predicate added
    (empty ?v - truck)
  )

  (:action WALK
    :parameters
      (?driver - driver
       ?loc-from - location
       ?loc-to - location)
    :precondition
      (and 
        (at ?driver ?loc-from)
        (path ?loc-from ?loc-to) ;; New precondition added here
        (not (exists (?v - truck) (driving ?driver ?v))) ;; Prevent walking while driving
      )
    :effect
      (and 
        (not (at ?driver ?loc-from))
        (at ?driver ?loc-to)
      )
  )

  (:action DRIVE
    :parameters
      (?driver - driver
       ?truck - truck
       ?loc-from - location
       ?loc-to - location)
    :precondition
      (and
        (at ?driver ?loc-from)
        (at ?truck ?loc-from)
        (empty ?truck)
        (path ?loc-from ?loc-to) ;; New precondition added here
      )
    :effect
      (and
        (not (at ?driver ?loc-from))
        (not (at ?truck ?loc-from))
        (at ?driver ?loc-to)
        (at ?truck ?loc-to)
        (driving ?driver ?truck) ;; New effect added here
      )
  )
)
