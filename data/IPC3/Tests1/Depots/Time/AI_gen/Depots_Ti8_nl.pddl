(define (domain Depot)
  (:requirements :typing :durative-actions :fluents)
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
    (clear ?x - surface)
  )

  (:functions 
    (distance ?x - place ?y - place)
    (speed ?t - truck)
    (weight ?c - crate)
    (power ?h - hoist)
  )

  (:durative-action drive
    :parameters (?t - truck ?from - place ?to - place)
    :duration (= ?duration 10)
    :condition (and
      (at start (at ?t ?from))
      (at start (not (at ?t ?to))))
    :effect (and
      (at end (not (at ?t ?from)))
      (at end (at ?t ?to)))
  )

  (:durative-action lift
    :parameters (?h - hoist ?c - crate ?s - surface)
    :duration (= ?duration 1)
    :condition (and
      (at start (clear ?s))
      (at start (on ?c ?s))
      (at start (available ?h))
      (at start (not (lifting ?h ?c))))
    :effect (and
      (at start (lifting ?h ?c))
      (at end (not (on ?c ?s)))
      (at end (not (clear ?s)))
      (at end (not (available ?h))))
  )

  (:durative-action drop
    :parameters (?h - hoist ?c - crate ?s - surface)
    :duration (= ?duration 1)
    :condition (and
      (at start (lifting ?h ?c))
      (at start (clear ?s)))
    :effect (and
      (at start (clear ?s))
      (at end (on ?c ?s))
      (at end (not (lifting ?h ?c)))
      (at end (available ?h)))
  )

  (:durative-action load
    :parameters (?h - hoist ?c - crate ?t - truck)
    :duration (= ?duration 3)
    :condition (and
      (at start (lifting ?h ?c))
      (at start (available ?h)))
    :effect (and
      (at start (lifting ?h ?c))
      (at end (in ?c ?t))
      (at end (not (lifting ?h ?c)))
      (at end (available ?h)))
  )

  (:durative-action unload
    :parameters (?h - hoist ?c - crate ?t - truck ?s - surface)
    :duration (= ?duration 4)
    :condition (and
      (at start (in ?c ?t))
      (at start (clear ?s))
      (at start (available ?h)))
    :effect (and
      (at start (lifting ?h ?c))
      (at end (on ?c ?s))
      (at end (not (in ?c ?t)))
      (at end (not (lifting ?h ?c)))
      (at end (available ?h)))
  )
)
