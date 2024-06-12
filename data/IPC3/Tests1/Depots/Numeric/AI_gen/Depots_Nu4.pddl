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
             (lifting ?x - hoist ?y - crate)
             (clear ?x - surface)
)

(:functions 
	(load_limit ?t - truck) 
	(current_load ?t - truck) 
	(weight ?c - crate)
	(fuel-cost)
)
	
(:action Drive
:parameters (?x - truck ?y - place ?z - place) 
:precondition (and (at ?x ?y))
:effect (and (not (at ?x ?y)) (at ?x ?z)
		(increase (fuel-cost) 10)))

(:action Load
:parameters (?x - hoist ?y - crate ?z - truck ?p - place)
:precondition (and (at ?x ?p) (at ?z ?p) (available ?x)
		(<= (+ (current_load ?z) (weight ?y)) (load_limit ?z)))
:effect (and (in ?y ?z) (available ?x)
		(increase (current_load ?z) (weight ?y))))

(:action Unload 
:parameters (?x - hoist ?y - crate ?z - truck ?p - place)
:precondition (and (at ?x ?p) (at ?z ?p) (available ?x) (in ?y ?z))
:effect (and (not (in ?y ?z)) (available ?x)
		(decrease (current_load ?z) (weight ?y))))

(:action Lift
:parameters (?h - hoist ?c - crate ?p - place ?s - surface)
:precondition (and (at ?h ?p) (at ?c ?p) (available ?h) (clear ?c) (on ?c ?s))
:effect (and (lifting ?h ?c) (not (available ?h)) (not (clear ?c)) (clear ?s) (increase (fuel-cost) 1)))

(:action Drop
:parameters (?h - hoist ?c - crate ?p - place ?s - surface)
:precondition (and (at ?h ?p) (lifting ?h ?c) (clear ?s))
:effect (and (not (lifting ?h ?c)) (available ?h) (on ?c ?s) (not (clear ?s)) (clear ?c)))

)
