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
      (fuel-cost)
      (load_limit ?x - truck)
      (current_load ?x - truck)
      (weight ?x - crate)
  )
  
  (:action Drive
    :parameters (?x - truck ?y - place ?z - place) 
    :precondition (and (at ?x ?y))
    :effect (and (not (at ?x ?y)) (at ?x ?z)
                (increase (fuel-cost) 10)))

  (:action Lift
    :parameters (?h - hoist ?c - crate ?s - surface)
    :precondition (and (available ?h) (on ?c ?s) (clear ?c))
    :effect (and (lifting ?h ?c)
                 (not (available ?h)) 
                 (not (on ?c ?s))
                 (increase (fuel-cost) 1)))

  (:action Drop
    :parameters (?h - hoist ?c - crate ?s - surface)
    :precondition (and (lifting ?h ?c) (clear ?s))
    :effect (and (on ?c ?s)
                 (clear ?c)
                 (available ?h)
                 (not (lifting ?h ?c))))

  (:action Load
    :parameters (?h - hoist ?c - crate ?t - truck)
    :precondition (and (lifting ?h ?c) (clear ?c)
                       (< (current_load ?t) (load_limit ?t)))
    :effect (and (in ?c ?t)
                 (not (lifting ?h ?c))
                 (available ?h)
                 (increase (current_load ?t) (weight ?c))))

  (:action Unload
    :parameters (?h - hoist ?c - crate ?t - truck ?s - surface)
    :precondition (and (in ?c ?t) (available ?h) (clear ?s))
    :effect (and (lifting ?h ?c)
                 (not (available ?h))
                 (not (in ?c ?t))
                 (decrease (current_load ?t) (weight ?c))))
)
