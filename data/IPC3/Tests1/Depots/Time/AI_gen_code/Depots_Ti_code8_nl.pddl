(define (domain Depot)
  (:requirements :typing :durative-actions :fluents)
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

  (:functions (distance ?x - place ?y - place)
              (speed ?t - truck)
              (weight ?c - crate)
              (power ?h - hoist))

  (:durative-action Drive
    :parameters (?t - truck ?p1 - place ?p2 - place)
    :duration (= ?duration (/ (distance ?p1 ?p2) (speed ?t)))
    :condition (and (at start (at ?t ?p1)))
    :effect (and (at start (not (at ?t ?p1)))
                 (at end (at ?t ?p2))))

  (:durative-action Lift
    :parameters (?h - hoist ?c - crate ?s - surface ?p - place)
    :duration (= ?duration 1)
    :condition (and (at start (at ?h ?p))
                    (at start (available ?h))
                    (at start (at ?c ?p))
                    (at start (on ?c ?s))
                    (at start (clear ?c)))
    :effect (and (at start (not (on ?c ?s)))
                 (at start (not (clear ?c)))
                 (at start (lifting ?h ?c))
                 (at end (not (lifting ?h ?c)))
                 (at end (clear ?s))))

  (:durative-action Drop
    :parameters (?h - hoist ?c - crate ?s - surface ?p - place)
    :duration (= ?duration 1)
    :condition (and (at start (at ?h ?p))
                    (at start (lifting ?h ?c))
                    (at start (clear ?s)))
    :effect (and (at start (not (lifting ?h ?c)))
                 (at start (not (clear ?s)))
                 (at end (on ?c ?s))
                 (at end (clear ?c))
                 (at end (available ?h))))

  (:durative-action Load
    :parameters (?h - hoist ?c - crate ?t - truck ?p - place)
    :duration (= ?duration (/ (weight ?c) (power ?h)))
    :condition (and (at start (at ?h ?p))
                    (at start (lifting ?h ?c))
                    (at start (at ?t ?p)))
    :effect (and (at start (not (lifting ?h ?c)))
                 (at end (in ?c ?t))
                 (at end (available ?h))))

  (:durative-action Unload
    :parameters (?h - hoist ?c - crate ?t - truck ?p - place)
    :duration (= ?duration (/ (weight ?c) (power ?h)))
    :condition (and (at start (at ?h ?p))
                    (at start (available ?h))
                    (at start (in ?c ?t))
                    (at start (at ?t ?p)))
    :effect (and (at start (not (in ?c ?t)))
                 (at end (lifting ?h ?c))
                 (at end (not (available ?h)))))
)
