(define (domain logistics)
  (:requirements :adl :fluents :universal-preconditions)

  (:types
    object 
    location 
    transport - object
    airplane truck - transport
    city airport - location
  )

  (:predicates 	
		(at ?obj - object ?loc - location)
		(in ?obj1 - object ?tr - transport))

(:action LOAD-TRUCK
  :parameters (?obj - object ?t - truck ?loc - location)
  :precondition (and (at ?t ?loc) (at ?obj ?loc))
  :effect (and (not (at ?obj ?loc)) (in ?obj ?t)))

(:action LOAD-AIRPLANE
  :parameters (?obj - object ?air - airplane ?loc - location)
  :precondition (and (at ?obj ?loc) (at ?air ?loc))
  :effect (and (not (at ?obj ?loc)) (in ?obj ?air)))

(:action UNLOAD-TRUCK
  :parameters (?obj - object ?tru - truck ?loc - location)
  :precondition (and (at ?tru ?loc) (in ?obj ?tru))
  :effect (and (not (in ?obj ?tru)) (at ?obj ?loc)))

(:action UNLOAD-AIRPLANE
  :parameters (?obj - object ?air - airplane ?loc - location)
  :precondition (and (in ?obj ?air) (at ?air ?loc)
  :effect (and (not (in ?obj ?air)) (at ?obj ?loc)))

(:action DRIVE-TRUCK
  :parameters (?tru - truck ?from ?to - location)
  :precondition (and (at ?tru ?from))
  :effect (and (not (at ?tru ?from)) (at ?tru ?to)))

(:action FLY-AIRPLANE
  :parameters (?air - airplane ?from ?to - location)
  :precondition (and (at ?air ?from))
  :effect (and (not (at ?air ?from)) (at ?air ?to)))
)
)