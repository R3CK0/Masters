; Remove lift and drop

(define (domain depot)
(:requirements :durative-actions)
(:predicates
	 (at ?x ?y) (on ?x ?y) (in ?x ?y) (available ?x) (clear ?x)(place ?x) (locatable ?x) (depot ?x) (distributor ?x) (truck ?x) (hoist ?x) (surface ?x) (pallet ?x) (crate ?x) )
(:durative-action drive
 :parameters ( ?x ?y ?z)
 :duration (= ?duration 10)
 :condition
	(and (at start (truck ?x)) (at start (place ?y)) (at start (place ?z))  (at start (at ?x ?y)))
 :effect
	(and (at end  (at ?x ?z)) (at start  (not (at ?x ?y)))))

(:durative-action load
 :parameters ( ?x ?y ?z ?p)
 :duration (= ?duration 3)
 :condition
	(and (at start (hoist ?x)) (at start (crate ?y)) (at start (truck ?z)) (at start (place ?p))  (over all (at ?x ?p)) (over all (at ?z ?p)))
 :effect
	(and (at end  (available ?x)) (at end  (in ?y ?z))))

(:durative-action unload
 :parameters ( ?x ?y ?z ?p)
 :duration (= ?duration 4)
 :condition
	(and (at start (hoist ?x)) (at start (crate ?y)) (at start (truck ?z)) (at start (place ?p))  (over all (at ?x ?p)) (over all (at ?z ?p)) (at start (available ?x)) (at start (in ?y ?z)))
 :effect
	(and (at start  (not (available ?x))) (at start  (not (in ?y ?z)))))

)
