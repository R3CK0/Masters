;Remove Lift and Drop actions

(define (domain Depot)
(:requirements :typing :durative-actions)
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

	
(:durative-action Drive
:parameters (?x - truck ?y - place ?z - place) 
:duration (= ?duration 10)
:condition (and (at start (at ?x ?y)))
:effect (and (at start (not (at ?x ?y))) (at end (at ?x ?z))))

(:durative-action Load
:parameters (?x - hoist ?y - crate ?z - truck ?p - place)
:duration (= ?duration 3)
:condition (and (over all (at ?x ?p)) (over all (at ?z ?p)))
:effect (and (at end (in ?y ?z)) (at end (available ?x))))

(:durative-action Unload 
:parameters (?x - hoist ?y - crate ?z - truck ?p - place)
:duration (= ?duration 4)
:condition (and (over all (at ?x ?p)) (over all (at ?z ?p)) (at start (available ?x)) (at start (in ?y ?z)))
:effect (and (at start (not (in ?y ?z))) (at start (not (available ?x)))))

)
