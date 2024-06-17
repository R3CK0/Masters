(define (domain Depot)
(:requirements :typing :fluents)
(:types place locatable - object
    depot distributor - place
    truck hoist surface - locatable
    pallet crate - surface)

(:predicates (at ?x - locatable ?y - place) 
             (on ?x - crate ?y - surface)
             (in ?x - crate ?y - truck)
             (lifting ?x - hoist ?y - crate)
             (available ?x - hoist)
             (clear ?x - surface)
             (inspected ?y - crate))

(:functions 
    (load_limit ?t - truck) 
    (current_load ?t - truck)
    (weight ?c - crate)
    (fuel-cost))

(:action Drive
:parameters (?x - truck ?y - place ?z - place)
:precondition (at ?x ?y)
:effect (and (not (at ?x ?y)) (at ?x ?z)
             (increase (fuel-cost) 10)))

(:action Lift
:parameters (?x - hoist ?y - crate ?z - surface ?p - place)
:precondition (and (at ?x ?p) (at ?y ?p) (on ?y ?z) (available ?x) (clear ?y) (clear ?z))
:effect (and (not (on ?y ?z)) (lifting ?x ?y) (not (clear ?y))
             (not (available ?x)) (clear ?z) (not (at ?y ?p))
             (increase (fuel-cost) 1)))

(:action Drop 
:parameters (?x - hoist ?y - crate ?z - surface ?p - place)
:precondition (and (lifting ?x ?y) (at ?x ?p) (clear ?z) (at ?z ?p))
:effect (and (not (lifting ?x ?y)) (on ?y ?z) (clear ?y)
              (available ?x) (not (clear ?z)) (at ?y ?p)))

(:action Load
:parameters (?x - hoist ?y - crate ?z - truck ?p - place)
:precondition (and (lifting ?x ?y) (at ?x ?p) (at ?z ?p) (inspected ?y)
             (<= (+ (current_load ?z) (weight ?y)) (load_limit ?z)))
:effect (and (not (lifting ?x ?y)) (in ?y ?z) (available ?x)
             (increase (current_load ?z) (weight ?y))))

(:action Unload 
:parameters (?x - hoist ?y - crate ?z - truck ?p - place)
:precondition (and (in ?y ?z) (at ?x ?p) (at ?z ?p) (available ?x))
:effect (and (not (in ?y ?z)) (lifting ?x ?y) (not (available ?x))
             (decrease (current_load ?z) (weight ?y))))

(:action Inspect
:parameters (?x - hoist ?y - crate ?p - place)
:precondition (and (at ?x ?p) (at ?y ?p) (available ?x))
:effect (and (inspected ?y) (increase (fuel-cost) 0.5)))
)
