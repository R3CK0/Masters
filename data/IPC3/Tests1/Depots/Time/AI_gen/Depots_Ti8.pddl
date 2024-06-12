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
    (clear ?x - surface))

  (:functions 
    (distance ?x - place ?y - place)
    (speed ?t - truck)
    (weight ?c - crate)
    (power ?h - hoist))

  (:durative-action Drive
    :parameters (?t - truck ?from - place ?to - place)
    :duration (= ?duration (/ (distance ?from ?to) (speed ?t)))
    :condition (and 
        (at start (at ?t ?from)))
    :effect (and 
        (at start (not (at ?t ?from)))
        (at end (at ?t ?to))))

  (:durative-action Load
    :parameters (?h - hoist ?t - truck ?c - crate ?p - place)
    :duration (= ?duration (/ (weight ?c) (power ?h)))
    :condition (and 
        (at start (at ?h ?p))
        (at start (at ?t ?p))
        (at start (lifting ?h ?c)))
    :effect (and 
        (at start (not (lifting ?h ?c)))
        (at end (in ?c ?t))
        (at end (available ?h))))

  (:durative-action Unload
    :parameters (?h - hoist ?t - truck ?c - crate ?p - place)
    :duration (= ?duration (/ (weight ?c) (power ?h)))
    :condition (and 
        (at start (at ?h ?p))
        (at start (at ?t ?p))
        (at start (in ?c ?t))
        (at start (available ?h)))
    :effect (and 
        (at end (not (in ?c ?t)))
        (at start (not (available ?h)))
        (at end (lifting ?h ?c))))

  (:durative-action Lift
    :parameters (?h - hoist ?c - crate ?p - place)
    :duration (= ?duration 1)
    :condition (and 
        (at start (at ?h ?p))
        (at start (at ?c ?p))
        (at start (available ?h))
        (at start (clear ?c)))
    :effect (and 
        (at start (not (available ?h)))
        (at start (not (clear ?c)))
        (at end (lifting ?h ?c))
        (at end (not (at ?c ?p)))))

  (:durative-action Drop
    :parameters (?h - hoist ?c - crate ?p - place ?s - surface)
    :duration (= ?duration 1)
    :condition (and 
        (at start (at ?h ?p))
        (at start (at ?s ?p))
        (at start (at ?c ?p))
        (at start (lifting ?h ?c))
        (at start (clear ?s)))
    :effect (and 
        (at end (not (lifting ?h ?c)))
        (at end (available ?h))
        (at end (on ?c ?s))
        (at end (clear ?c))
        (at end (not (clear ?s)))))

)
