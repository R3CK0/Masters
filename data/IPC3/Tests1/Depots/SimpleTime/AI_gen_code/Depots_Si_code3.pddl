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
:parameters (?t - truck ?p1 - place ?p2 - place)
:duration (= ?duration 2)
:condition (at start (at ?t ?p1))
:effect (and (at start (not (at ?t ?p1)))
             (at end (at ?t ?p2))))

(:durative-action Lift
:parameters (?h - hoist ?c - crate ?s - surface ?p - place)
:duration (= ?duration 1)
:condition (and (over all (at ?h ?p))
                (at start (available ?h)) 
                (at start (at ?c ?p)) 
                (at start (on ?c ?s)) 
                (at start (clear ?c)))
:effect (and (at start (not (at ?c ?p)))
             (at start (lifting ?h ?c))
             (at start (not (clear ?c)))
             (at start (not (available ?h)))
             (at start (clear ?s))
             (at start (not (on ?c ?s)))))

(:durative-action Drop 
:parameters (?h - hoist ?c - crate ?s - surface ?p - place)
:duration (= ?duration 1)
:condition (and (over all (at ?h ?p))
                (over all (lifting ?h ?c))
                (over all (at ?s ?p))
                (over all (clear ?s)))
:effect (and (at end (available ?h))
             (at end (not (lifting ?h ?c)))
             (at end (at ?c ?p))
             (at end (not (clear ?s)))
             (at end (clear ?c))
             (at end (on ?c ?s))))

(:durative-action Load
:parameters (?h - hoist ?c - crate ?t - truck ?p - place)
:duration (= ?duration 3)
:condition (and (over all (at ?h ?p))
                (over all (at ?t ?p))
                (over all (lifting ?h ?c)))
:effect (and (at end (not (lifting ?h ?c)))
             (at end (available ?h))
             (at end (in ?c ?t))))

(:durative-action Unload 
:parameters (?h - hoist ?c - crate ?t - truck ?p - place)
:duration (= ?duration 4)
:condition (and (over all (at ?h ?p))
                (over all (at ?t ?p))
                (at start (available ?h))
                (at start (in ?c ?t)))
:effect (and (at start (not (in ?c ?t)))
             (at start (lifting ?h ?c))
             (at start (not (available ?h)))))

)
