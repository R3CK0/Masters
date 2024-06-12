(define (domain Depot)
  (:requirements :typing)
  (:types place locatable - object
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
    :parameters (?h - hoist ?c - crate ?s - surface)
    :precondition (and (at ?h ?p) (at ?c ?p) (on ?c ?s) (clear ?c) (available ?h))
    :effect (and (lifting ?h ?c) (not (available ?h)) (not (on ?c ?s)) (clear ?s)))

  (:action Drop
    :parameters (?h - hoist ?c - crate ?s - surface)
    :precondition (and (lifting ?h ?c) (clear ?s))
    :effect (and (available ?h) (not (lifting ?h ?c)) (on ?c ?s) (not (clear ?s))))

  (:action Load
    :parameters (?h - hoist ?c - crate ?t - truck)
    :precondition (and (lifting ?h ?c) (at ?t ?p) (at ?h ?p) (at ?c ?p))
    :effect (and (in ?c ?t) (available ?h) (not (lifting ?h ?c))))

  (:action Unload
    :parameters (?h - hoist ?c - crate ?t - truck ?s - surface)
    :precondition (and (in ?c ?t) (available ?h) (clear ?s) (at ?t ?p) (at ?h ?p))
    :effect (and (lifting ?h ?c) (not (available ?h)) (not (in ?c ?t)) (on ?c ?s) (not (clear ?s))))
)
