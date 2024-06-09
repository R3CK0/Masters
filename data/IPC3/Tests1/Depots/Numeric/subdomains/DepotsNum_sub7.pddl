;Removed lift, drop, load and unload actions with relevant predicates

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
	(fuel-cost)
)
	
(:action Drive
:parameters (?x - truck ?y - place ?z - place) 
:precondition (and (at ?x ?y))
:effect (and (not (at ?x ?y)) (at ?x ?z)
		(increase (fuel-cost) 10)))

)