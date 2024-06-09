; Remove lif and drop

(define (domain depot)
(:requirements :fluents)
(:predicates
	 (at ?x ?y) 
	 (on ?x ?y) 
	 (in ?x ?y) 
	 (available ?x) 
	 (clear ?x)
	 (place ?x) 
	 (locatable ?x) 
	 (depot ?x) 
	 (distributor ?x) 
	 (truck ?x) 
	 (hoist ?x) 
	 (surface ?x) 
	 (pallet ?x) 
	 (crate ?x))
(:functions
	 (fuel-cost))
(:action drive
 :parameters ( ?x ?y ?z)
 :precondition
	(and (truck ?x) (place ?y) (place ?z)  (at ?x ?y))
 :effect
	(and (at ?x ?z) (not (at ?x ?y)) (increase (fuel-cost) 10)))

(:action load
 :parameters ( ?x ?y ?z ?p)
 :precondition
	(and (hoist ?x) (crate ?y) (truck ?z) (place ?p)  (at ?x ?p) (at ?z ?p) (on ?y ?z) (clear ?y))
 :effect
	(and (in ?y ?z) (available ?x) (not (on ?y ?z)) (increase (fuel-cost) 1)))

(:action unload
 :parameters ( ?x ?y ?z ?p)
 :precondition
	(and (hoist ?x) (crate ?y) (truck ?z) (place ?p)  (at ?x ?p) (at ?z ?p) (available ?x) (in ?y ?z))
 :effect
	(and (on ?y ?z) (not (in ?y ?z)) (increase (fuel-cost) 1)))

)

