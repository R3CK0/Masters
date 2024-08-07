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
             (clear ?x - surface)
             (day))

(:functions (distance ?x - place ?y - place)
	    (speed ?t - truck)
	    (weight ?c - crate)
	    (power ?h - hoist))
	
(:durative-action Drive
:parameters (?x - truck ?y - place ?z - place) 
:duration (= ?duration (/ (distance ?y ?z) (speed ?x)))
:condition (and (at start (at ?x ?y)) (over all (day)))
:effect (and (at start (not (at ?x ?y))) (at end (at ?x ?z))))

(:durative-action Lift
:parameters (?x - hoist ?y - crate ?z - surface ?p - place)
:duration (= ?duration 1)
:condition (and (at start (at ?x ?p)) (at start (available ?x)) (at start (at ?y ?p)) 
                (at start (on ?y ?z)) (at start (clear ?y)) (over all (day)))
:effect (and (at start (not (at ?y ?p))) (at start (lifting ?x ?y)) (at start (not (clear ?y))) 
             (at start (not (available ?x))) (at start (clear ?z)) (at end (not (on ?y ?z)))))

(:durative-action Drop 
:parameters (?x - hoist ?y - crate ?z - surface ?p - place)
:duration (= ?duration 1)
:condition (and (at start (at ?x ?p)) (at start (available ?x)) (over all (lifting ?x ?y)) (over all (day)))
:effect (and (at end (available ?x)) (at end (not (lifting ?x ?y))) (at end (at ?y ?p)) 
              (at end (on ?y ?z)) (at end (clear ?y)) (at end (not (clear ?z)))))

(:durative-action Load
:parameters (?x - hoist ?y - crate ?z - truck ?p - place)
:duration (= ?duration (/ (weight ?y) (power ?x)))
:condition (and (at start (at ?x ?p)) (at start (at ?z ?p)) (at start (lifting ?x ?y)) (over all (day)))
:effect (and (at end (not (lifting ?x ?y))) (at end (in ?y ?z)) (at end (available ?x))))

(:durative-action Unload 
:parameters (?x - hoist ?y - crate ?z - truck ?p - place)
:duration (= ?duration (/ (weight ?y) (power ?x)))
:condition (and (at start (at ?x ?p)) (at start (available ?x)) (at start (in ?y ?z)) (at start (at ?z ?p)) (over all (day)))
:effect (and (at end (not (in ?y ?z))) (at end (lifting ?x ?y)) (at end (not (available ?x)))))

)
