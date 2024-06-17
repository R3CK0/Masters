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

(:action Lift
 :parameters (?h - hoist ?c - crate ?s - surface ?p - place)
 :precondition (and (at ?h ?p) (available ?h) (at ?c ?p) (on ?c ?s) (clear ?c))
 :effect (and (not (available ?h)) (lifting ?h ?c) (not (on ?c ?s)) (not (clear ?c)) (clear ?s) (not (at ?c ?p))))

(:action Drop
 :parameters (?h - hoist ?c - crate ?s - surface ?p - place)
 :precondition (and (at ?h ?p) (lifting ?h ?c) (clear ?s) (at ?s ?p))
 :effect (and (available ?h) (not (lifting ?h ?c)) (on ?c ?s) (clear ?c) (not (clear ?s)) (at ?c ?p)))

(:action Load
 :parameters (?h - hoist ?c - crate ?t - truck ?p - place)
 :precondition (and (at ?h ?p) (lifting ?h ?c) (at ?t ?p))
 :effect (and (not (lifting ?h ?c)) (not (available ?h)) (in ?c ?t)))

(:action Unload
 :parameters (?h - hoist ?c - crate ?t - truck ?p - place)
 :precondition (and (at ?h ?p) (available ?h) (in ?c ?t) (at ?t ?p))
 :effect (and (lifting ?h ?c) (not (available ?h)) (not (in ?c ?t))))
)
