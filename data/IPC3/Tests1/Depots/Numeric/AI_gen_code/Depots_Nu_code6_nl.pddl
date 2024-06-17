(define (domain Depot)
  (:requirements :typing :fluents)
  (:types place locatable - object
          depot distributor - place
          truck hoist surface - locatable
          pallet crate - surface)

  (:predicates (at ?x - locatable ?y - place) 
               (on ?x - crate ?y - surface)
               (in ?x - crate ?y - truck)
               (available ?x - hoist)
               (clear ?x - surface)
               (lifting ?h - hoist ?c - crate))

  (:functions 
    (fuel-cost)
    (load_limit ?t - truck)
    (current_load ?t - truck)
    (weight ?c - crate))

  (:action Drive
    :parameters (?x - truck ?y - place ?z - place) 
    :precondition (and (at ?x ?y))
    :effect (and (not (at ?x ?y)) (at ?x ?z)
                 (increase (fuel-cost) 10)))

  (:action Load
    :parameters (?h - hoist ?c - crate ?t - truck ?p - place)
    :precondition (and (at ?h ?p) 
                       (at ?t ?p)
                       (lifting ?h ?c)
                       (<= (+ (current_load ?t) (weight ?c)) (load_limit ?t)))
    :effect (and (not (lifting ?h ?c)) 
                 (in ?c ?t)
                 (assign (current_load ?t) (+ (current_load ?t) (weight ?c)))))

  (:action Unload
    :parameters (?h - hoist ?c - crate ?t - truck ?p - place)
    :precondition (and (at ?h ?p) 
                       (at ?t ?p)
                       (in ?c ?t)
                       (available ?h))
    :effect (and (lifting ?h ?c) 
                 (not (in ?c ?t))
                 (assign (current_load ?t) (- (current_load ?t) (weight ?c)))))

  (:action Lift
    :parameters (?h - hoist ?c - crate ?s - surface ?p - place)
    :precondition (and (at ?h ?p)
                       (at ?c ?p)
                       (on ?c ?s)
                       (clear ?c)
                       (available ?h))
    :effect (and (not (on ?c ?s)) 
                 (lifting ?h ?c)
                 (not (available ?h))
                 (increase (fuel-cost) 1)))

  (:action Drop
    :parameters (?h - hoist ?c - crate ?s - surface ?p - place)
    :precondition (and (at ?h ?p)
                       (lifting ?h ?c)
                       (at ?s ?p)
                       (clear ?s))
    :effect (and (on ?c ?s) 
                 (not (lifting ?h ?c))
                 (available ?h)))
)
