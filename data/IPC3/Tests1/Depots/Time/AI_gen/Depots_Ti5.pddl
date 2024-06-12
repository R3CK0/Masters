(define (domain Depot)
(:requirements :typing :durative-actions :fluents)
(:types place locatable - object
	depot distributor - place
    truck hoist surface - locatable
    pallet crate - surface)

(:predicates (at ?x - locatable ?y - place) 
             (on ?x - crate ?y - surface)
             (lifting ?x - hoist ?y - crate)
             (available ?x - hoist)
             (clear ?x - surface)
             (in-truck ?x - crate ?t - truck))

(:functions (weight ?c - crate)
            (power ?h - hoist)
            (distance ?p1 ?p2 - place)
            (speed ?t - truck))

(:durative-action Lift
:parameters (?x - hoist ?y - crate ?z - surface ?p - place)
:duration (= ?duration 1)
:condition (and (over all (at ?x ?p)) (at start (available ?x)) (at start (at ?y ?p)) (at start (on ?y ?z)) (at start (clear ?y)))
:effect (and (at start (not (at ?y ?p))) (at start (lifting ?x ?y)) (at start (not (clear ?y))) (at start (not (available ?x))) 
             (at start (clear ?z)) (at start (not (on ?y ?z)))))

(:durative-action Drop 
:parameters (?x - hoist ?y - crate ?z - surface ?p - place)
:duration (= ?duration 1)
:condition (and (over all (at ?x ?p)) (over all (at ?z ?p)) (over all (clear ?z)) (over all (lifting ?x ?y)))
:effect (and (at end (available ?x)) (at end (not (lifting ?x ?y))) (at end (at ?y ?p)) (at end (not (clear ?z))) (at end (clear ?y))
		(at end (on ?y ?z))))

(:durative-action Load
:parameters (?x - hoist ?c - crate ?t - truck ?p - place)
:duration (= ?duration (/ (weight ?c) (power ?x)))
:condition (and (at start (at ?x ?p)) (at start (at ?t ?p)) (at start (lifting ?x ?c)))
:effect (and (at start (not (lifting ?x ?c))) (at start (not (available ?x))) (at end (available ?x)) (at end (in-truck ?c ?t))))

(:durative-action Unload
:parameters (?x - hoist ?c - crate ?t - truck ?p - place)
:duration (= ?duration (/ (weight ?c) (power ?x)))
:condition (and (at start (at ?x ?p)) (at start (at ?t ?p)) (at start (available ?x)) (at start (in-truck ?c ?t)))
:effect (and (at start (not (in-truck ?c ?t))) (at start (not (available ?x))) (at end (lifting ?x ?c)) (at end (not (available ?x)))))

(:durative-action Drive
:parameters (?t - truck ?p1 - place ?p2 - place)
:duration (= ?duration (/ (distance ?p1 ?p2) (speed ?t)))
:condition (at start (at ?t ?p1))
:effect (and (at start (not (at ?t ?p1))) (at end (at ?t ?p2))))
)
