(define (domain Depot)
  (:requirements :typing :fluents)
  (:types place locatable - object
          depot distributor - place
          truck hoist surface - locatable
          pallet crate - surface)

  (:predicates (at ?x - locatable ?y - place) 
               (on ?x - crate ?y - surface)
               (in ?x - crate ?y - truck)
               (available ?x - hoist)
               (clear ?x - surface)
               (lifting ?x - hoist ?c - crate)
               (inside ?c - crate ?t - truck))

  (:functions 
    (load_limit ?t - truck) 
    (current_load ?t - truck) 
    (weight ?c - crate)
    (fuel-cost) )

  (:action Drive
    :parameters (?x - truck ?y - place ?z - place) 
    :precondition (and (at ?x ?y))
    :effect (and (not (at ?x ?y)) (at ?x ?z)
               (increase (fuel-cost) 10)))

  (:action Lift
    :parameters (?x - hoist ?y - crate ?p - pallet ?pl - place)
    :precondition (and (at ?x ?pl) (at ?p ?pl) (on ?y ?p) (clear ?y) (available ?x))
    :effect (and (not (on ?y ?p)) (not (clear ?y)) 
               (lifting ?x ?y) (not (available ?x))
               (increase (fuel-cost) 1)))

  (:action Drop
    :parameters (?x - hoist ?y - crate ?p - pallet ?pl - place)
    :precondition (and (at ?x ?pl) (lifting ?x ?y) (clear ?p))
    :effect (and (on ?y ?p) (clear ?y) (available ?x)
               (not (lifting ?x ?y)) 
               (not (clear ?p))))

  (:action Load
    :parameters (?x - hoist ?y - crate ?z - truck ?pl - place)
    :precondition (and (at ?x ?pl) (at ?z ?pl) (lifting ?x ?y)
                      (<= (+ (current_load ?z) (weight ?y)) (load_limit ?z)))
    :effect (and (in ?y ?z) (not (lifting ?x ?y)) (available ?x)
               (increase (current_load ?z) (weight ?y))
               (lifting ?x ?y)))

  (:action Unload 
    :parameters (?x - hoist ?y - crate ?z - truck ?pl - place)
    :precondition (and (at ?x ?pl) (at ?z ?pl) (available ?x) (in ?y ?z))
    :effect (and (not (in ?y ?z)) (decrease (current_load ?z) (weight ?y))
               (available ?x) (lifting ?x ?y)))

)
