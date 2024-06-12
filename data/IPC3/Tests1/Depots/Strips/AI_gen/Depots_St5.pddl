(define (domain Depot)
(:requirements :typing)
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

(:action Drive
:parameters (?x - truck ?y - place ?z - place) 
:precondition (and (at ?x ?y))
:effect (and (not (at ?x ?y)) (at ?x ?z)))

(:action Load
:parameters (?h - hoist ?c - crate ?t - truck ?p - place)
:precondition (and (at ?h ?p) (at ?t ?p) (lifting ?h ?c))
:effect (and (not (lifting ?h ?c)) (available ?h) (in ?c ?t)))

(:action Unload
:parameters (?h - hoist ?c - crate ?t - truck ?p - place)
:precondition (and (at ?h ?p) (at ?t ?p) (available ?h) (in ?c ?t))
:effect (and (not (in ?c ?t)) (lifting ?h ?c) (not (available ?h))))

(:action Lift
:parameters (?h - hoist ?c - crate ?s - surface ?p - place)
:precondition (and (at ?h ?p) (at ?c ?p) (available ?h) (on ?c ?s) (clear ?c) (clear ?s))
:effect (and (not (on ?c ?s)) (lifting ?h ?c) (not (clear ?s)) (not (clear ?c)) (not (available ?h)) (not (at ?c ?p))))

(:action Drop
:parameters (?h - hoist ?c - crate ?s - surface ?p - place)
:precondition (and (at ?h ?p) (at ?s ?p) (lifting ?h ?c) (clear ?s))
:effect (and (on ?c ?s) (clear ?c) (available ?h) (not (lifting ?h ?c)) (not (clear ?s))))
)
