(define (domain Depot)
  (:requirements :typing)
  (:types place locatable - object
          depot distributor - place
          truck hoist surface - locatable
          pallet crate - surface)

  (:predicates 
    (at ?x - locatable ?y - place) 
    (on ?x - crate ?y - surface)
    (in ?x - crate ?y - truck)
    (available ?x - hoist)
    (clear ?x - surface)
    (lifting ?x - hoist ?y - crate))

  (:action Drive
    :parameters (?x - truck ?y - place ?z - place) 
    :precondition (and (at ?x ?y))
    :effect (and (not (at ?x ?y)) (at ?x ?z)))

  (:action Load
    :parameters (?x - hoist ?y - crate ?z - truck ?p - place)
    :precondition (and (at ?x ?p) (at ?z ?p) (lifting ?x ?y))
    :effect (and (not (lifting ?x ?y)) (in ?y ?z) (available ?x)))

  (:action Unload 
    :parameters (?x - hoist ?y - crate ?z - truck ?p - place)
    :precondition (and (at ?x ?p) (at ?z ?p) (available ?x) (in ?y ?z))
    :effect (and (not (in ?y ?z)) (not (available ?x)) (lifting ?x ?y)))

  (:action Lift
    :parameters (?x - hoist ?y - crate ?p - place ?s - surface)
    :precondition (and (at ?x ?p) (at ?s ?p) (on ?y ?s) (available ?x) (clear ?y))
    :effect (and (not (on ?y ?s)) (lifting ?x ?y) (available ?x) (clear ?s)))

  (:action Drop
    :parameters (?x - hoist ?y - crate ?p - place ?s - surface)
    :precondition (and (at ?x ?p) (at ?s ?p) (lifting ?x ?y) (clear ?s))
    :effect (and (not (lifting ?x ?y)) (on ?y ?s) (available ?x) (not (clear ?s)) (clear ?y)))
)
