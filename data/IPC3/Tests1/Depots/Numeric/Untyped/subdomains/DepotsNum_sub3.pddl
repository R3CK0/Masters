; Remove drive action

(define (domain depot)
(:requirements :fluents)
(:predicates
	 (at ?x ?y) (on ?x ?y) (in ?x ?y) (lifting ?x ?y) (available ?x) (clear ?x)(place ?x) (locatable ?x) (depot ?x) (distributor ?x) (truck ?x) (hoist ?x) (surface ?x) (pallet ?x) (crate ?x) )
(:functions
	 (load_limit ?t) (current_load ?t) (weight ?c) (fuel-cost))



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

(:action load
 :parameters ( ?x ?y ?z ?p)
 :precondition
	(and (hoist ?x) (crate ?y) (truck ?z) (place ?p)  (at ?x ?p) (at ?z ?p) (lifting ?x ?y) (<= (+ (current_load ?z) (weight ?y)) (load_limit ?z)))
 :effect
	(and (in ?y ?z) (available ?x) (not (lifting ?x ?y)) (increase (current_load ?z) (weight ?y))))

(:action unload
 :parameters ( ?x ?y ?z ?p)
 :precondition
	(and (hoist ?x) (crate ?y) (truck ?z) (place ?p)  (at ?x ?p) (at ?z ?p) (available ?x) (in ?y ?z))
 :effect
	(and (lifting ?x ?y) (not (in ?y ?z)) (not (available ?x)) (decrease (current_load ?z) (weight ?y))))

)
