;Remove load and unload

(define (domain depot)
(:requirements :fluents)
(:predicates
	 (at ?x ?y) (on ?x ?y) (lifting ?x ?y) (available ?x) (clear ?x) (place ?x) (locatable ?x) (depot ?x) (distributor ?x) (truck ?x) (hoist ?x) (surface ?x) (pallet ?x) (crate ?x))
(:functions
	 (fuel-cost))
(:action drive
 :parameters ( ?x ?y ?z)
 :precondition
	(and (truck ?x) (place ?y) (place ?z)  (at ?x ?y))
 :effect
	(and (at ?x ?z) (not (at ?x ?y)) (increase (fuel-cost) 10)))

(:action lift
 :parameters ( ?x ?y ?z ?p)
 :precondition
	(and (hoist ?x) (crate ?y) (surface ?z) (place ?p)  (at ?x ?p) (available ?x) (at ?y ?p) (on ?y ?z) (clear ?y))
 :effect
	(and (lifting ?x ?y) (clear ?z) (not (at ?y ?p)) (not (clear ?y)) (not (available ?x)) (not (on ?y ?z)) (increase (fuel-cost) 1)))

(:action drop
 :parameters ( ?x ?y ?z ?p)
 :precondition
	(and (hoist ?x) (crate ?y) (surface ?z) (place ?p)  (at ?x ?p) (at ?z ?p) (clear ?z) (lifting ?x ?y))
 :effect
	(and (available ?x) (at ?y ?p) (clear ?y) (on ?y ?z) (not (lifting ?x ?y)) (not (clear ?z))))

)

