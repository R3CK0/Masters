;Removed lift and drop actions with relevant predicates

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

)