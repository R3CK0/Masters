(define (domain Depot)
(:requirements :typing :fluents)
(:types place locatable - object
	depot distributor - place
        truck hoist surface - locatable
        pallet crate - surface)

(:predicates (at ?x - locatable ?y - place) 
             (on ?x - crate ?y - surface)
             (lifting ?x - hoist ?y - crate)
             (available ?x - hoist)
             (clear ?x - surface)
             (in ?x - crate ?y - truck) ; New predicate
)

(:functions 
	(fuel-cost)
    (load_limit ?t - truck) ; New function
    (current_load ?t - truck) ; New function
    (weight ?c - crate) ; New function
)

(:action Lift
:parameters (?x - hoist ?y - crate ?z - surface ?p - place)
:precondition (and (at ?x ?p) (available ?x) (at ?y ?p) (on ?y ?z) (clear ?y))
:effect (and (not (at ?y ?p)) (lifting ?x ?y) (not (clear ?y)) (not (available ?x)) 
             (clear ?z) (not (on ?y ?z)) (increase (fuel-cost) 1)))

(:action Drop 
:parameters (?x - hoist ?y - crate ?z - surface ?p - place)
:precondition (and (at ?x ?p) (at ?z ?p) (clear ?z) (lifting ?x ?y))
:effect (and (available ?x) (not (lifting ?x ?y)) (at ?y ?p) (not (clear ?z)) (clear ?y)
		(on ?y ?z)))

(:action Load
:parameters (?h - hoist ?c - crate ?t - truck ?p - place)
:precondition (and (lifting ?h ?c) (at ?t ?p) (at ?h ?p) 
                   (<= (+ (current_load ?t) (weight ?c)) (load_limit ?t)))
:effect (and (not (lifting ?h ?c)) (in ?c ?t) (available ?h)
             (increase (current_load ?t) (weight ?c))))

(:action Unload
:parameters (?h - hoist ?c - crate ?t - truck ?z - surface ?p - place)
:precondition (and (in ?c ?t) (at ?t ?p) (at ?h ?p) (at ?z ?p) (clear ?z) (available ?h))
:effect (and (lifting ?h ?c) (not (in ?c ?t)) (available ?h)
             (decrease (current_load ?t) (weight ?c)) (not (clear ?z))))

(:action Drive
:parameters (?t - truck ?from - place ?to - place)
:precondition (at ?t ?from)
:effect (and (not (at ?t ?from)) (at ?t ?to) (increase (fuel-cost) 10)))

)
