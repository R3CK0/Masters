; Removed all actions except Drive

(define (domain Depot)
(:requirements :typing :durative-actions :fluents)
(:types place locatable - object
	depot distributor - place
        truck hoist surface - locatable
        pallet crate - surface)

(:predicates (at ?x - locatable ?y - place) 
             (on ?x - crate ?y - surface)
             (in ?x - crate ?y - truck)
             (lifting ?x - hoist ?y - crate)
             (available ?x - hoist)
             (clear ?x - surface))

(:functions (distance ?x - place ?y - place)
	    (speed ?t - truck)
	    (weight ?c - crate)
	    (power ?h - hoist))
	
(:durative-action Drive
:parameters (?x - truck ?y - place ?z - place) 
:duration (= ?duration (/ (distance ?y ?z) (speed ?x)))
:condition (and (at start (at ?x ?y)))
:effect (and (at start (not (at ?x ?y))) (at end (at ?x ?z))))

)
