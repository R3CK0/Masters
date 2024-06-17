(define (domain Depot)
  (:requirements :typing :fluents)
  (:types place locatable - object
          depot distributor - place
          truck hoist surface - locatable
          pallet crate - surface)

  (:predicates 
    (at ?x - locatable ?y - place)
    (on ?x - crate ?y - surface)
    (in ?x - crate ?y - truck)
    (available ?x - hoist)
    (clear ?x - surface)
    (lifting ?x - hoist ?y - crate)
  )

  (:functions 
    (load_limit ?t - truck)
    (current_load ?t - truck)
    (weight ?c - crate)
    (fuel-cost)
  )

  (:action Drive
    :parameters (?x - truck ?y - place ?z - place)
    :precondition (and (at ?x ?y))
    :effect (and (not (at ?x ?y)) (at ?x ?z)
                 (increase (fuel-cost) 10))
  )

  (:action Load
    :parameters (?h - hoist ?c - crate ?t - truck ?p - place)
    :precondition (and (at ?h ?p) (at ?t ?p) (available ?h)
                       (lifting ?h ?c)
                       (<= (+ (current_load ?t) (weight ?c)) (load_limit ?t)))
    :effect (and (in ?c ?t) 
                 (available ?h)
                 (not (lifting ?h ?c))
                 (increase (current_load ?t) (weight ?c))))

  (:action Unload
    :parameters (?h - hoist ?c - crate ?t - truck ?p - place)
    :precondition (and (at ?h ?p) (at ?t ?p) (available ?h) (in ?c ?t))
    :effect (and (not (in ?c ?t)) 
                 (available ?h)
                 (lifting ?h ?c)
                 (decrease (current_load ?t) (weight ?c))))

  (:action Lift
    :parameters (?h - hoist ?c - crate ?s - surface ?p - place)
    :precondition (and (at ?h ?p) (at ?s ?p) 
                       (clear ?c) (on ?c ?s) 
                       (available ?h))
    :effect (and (lifting ?h ?c)
                 (not (on ?c ?s))
                 (not (clear ?c))
                 (not (clear ?s))
                 (increase (fuel-cost) 1)))

  (:action Drop
    :parameters (?h - hoist ?c - crate ?s - surface ?p - place)
    :precondition (and (at ?h ?p) (at ?s ?p) (lifting ?h ?c)
                       (clear ?s))
    :effect (and (not (lifting ?h ?c))
                 (on ?c ?s)
                 (clear ?c)
                 (not (clear ?s))
                 (available ?h)))
)
