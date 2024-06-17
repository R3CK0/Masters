(define (domain Depot)
  (:requirements :typing)
  (:types
    place locatable - object
    depot distributor - place
    truck hoist surface - locatable
    pallet crate - surface)

  (:predicates
    (at ?x - locatable ?y - place)
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
    :effect (and (lifting ?h ?c) (not (on ?c ?s)) (not (clear ?p)) (not (available ?h))))

  (:action Drop
    :parameters (?h - hoist ?c - crate ?s - surface ?p - place)
    :precondition (and (at ?h ?p) (lifting ?h ?c) (clear ?s) (at ?s ?p))
    :effect (and (not (lifting ?h ?c)) (on ?c ?s) (available ?h) (not (clear ?s))))

  (:action Load
    :parameters (?h - hoist ?c - crate ?t - truck ?p - place)
    :precondition (and (at ?h ?p) (lifting ?h ?c) (at ?t ?p))
    :effect (and (in ?c ?t) (not (lifting ?h ?c)) (available ?h)))

  (:action Unload
    :parameters (?h - hoist ?c - crate ?t - truck ?p - place)
    :precondition (and (at ?h ?p) (available ?h) (in ?c ?t) (at ?t ?p))
    :effect (and (lifting ?h ?c) (not (in ?c ?t)) (not (available ?h))))
)
