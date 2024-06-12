(define (domain Depot)
	(:requirements :typing)
	(:types place locatable - object
	        depot distributor - place
	        truck hoist surface - locatable
	        pallet crate - surface)

	(:predicates (at ?x - locatable ?y - place) 
	             (on ?x - crate ?y - surface)
	             (in ?x - crate ?y - truck)
	             (available ?x - hoist)
	             (clear ?x - surface)
	             (lifting ?x - hoist ?y - crate)) ; added lifting predicate

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

	; New action Lift
	(:action Lift
		:parameters (?x - hoist ?y - crate ?z - surface ?p - place)
		:precondition (and (at ?x ?p) (on ?y ?z) (clear ?y) (available ?x))
		:effect (and (lifting ?x ?y) (not (on ?y ?z)) (not (available ?x)))) ; lift the crate from the surface

	; New action Drop
	(:action Drop
		:parameters (?x - hoist ?y - crate ?z - surface ?p - place)
		:precondition (and (at ?x ?p) (lifting ?x ?y) (clear ?z))
		:effect (and (not (lifting ?x ?y)) (on ?y ?z) (available ?x))) ; drop the crate onto the surface
)
