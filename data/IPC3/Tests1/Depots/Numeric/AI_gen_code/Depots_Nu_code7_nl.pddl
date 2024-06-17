(define (domain Depot)
  (:requirements :typing :fluents)
  (:types
    place locatable - object
    depot distributor - place
    truck hoist surface - locatable
    pallet crate - surface
  )

  (:predicates
    (at ?x - locatable ?y - place) 
    (on ?x - crate ?y - surface)
    (in ?x - crate ?y - truck)
    (lifting ?x - hoist ?y - crate)
    (available ?x - hoist)
    (clear ?x - surface)
  )

  (:functions 
    (load_limit ?t - truck) 
    (current_load ?t - truck) 
    (weight ?c - crate)
    (fuel-cost)
  )

  (:action Drive
    :parameters (?t - truck ?p1 - place ?p2 - place)
    :precondition (and (at ?t ?p1))
    :effect (and
      (not (at ?t ?p1))
      (at ?t ?p2)
      (increase (fuel-cost) 10)
    )
  )

  (:action Lift
    :parameters (?h - hoist ?c - crate ?s - surface ?p - place)
    :precondition (and
      (at ?h ?p)
      (available ?h)
      (at ?c ?p)
      (on ?c ?s)
      (clear ?c)
      (clear ?s)
    )
    :effect (and
      (not (on ?c ?s))
      (lifting ?h ?c)
      (not (available ?h))
      (increase (fuel-cost) 1)
    )
  )

  (:action Drop
    :parameters (?h - hoist ?c - crate ?s - surface ?p - place)
    :precondition (and
      (lifting ?h ?c)
      (at ?h ?p)
      (at ?s ?p)
      (clear ?s)
    )
    :effect (and
      (on ?c ?s)
      (not (lifting ?h ?c))
      (available ?h)
      (clear ?c)
      (not (clear ?s))
    )
  )

  (:action Load
    :parameters (?h - hoist ?c - crate ?t - truck ?p - place)
    :precondition (and
      (at ?h ?p)
      (lifting ?h ?c)
      (at ?t ?p)
      (<= (+ (current_load ?t) (weight ?c)) (load_limit ?t))
    )
    :effect (and
      (in ?c ?t)
      (not (lifting ?h ?c))
      (available ?h)
      (increase (current_load ?t) (weight ?c))
    )
  )

  (:action Unload
    :parameters (?h - hoist ?c - crate ?t - truck ?p - place)
    :precondition (and
      (at ?h ?p)
      (available ?h)
      (in ?c ?t)
      (at ?t ?p)
    )
    :effect (and
      (not (in ?c ?t))
      (lifting ?h ?c)
      (not (available ?h))
      (decrease (current_load ?t) (weight ?c))
    )
  )
)
