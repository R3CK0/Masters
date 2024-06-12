(define (domain Depot)
  (:requirements :typing :durative-actions :fluents)
  (:types place locatable - object
          depot distributor - place
          truck hoist surface - locatable
          pallet crate - surface)

  (:predicates (at ?x - locatable ?y - place)
               (on ?x - crate ?y - surface)
               (in ?x - crate ?y - truck)
               (available ?x - hoist)
               (lifting ?x - hoist ?y - crate))

  (:functions (distance ?x - place ?y - place)
              (speed ?t - truck)
              (weight ?c - crate)
              (power ?h - hoist))

  (:durative-action Drive
    :parameters (?x - truck ?y - place ?z - place)
    :duration (= ?duration (/ (distance ?y ?z) (speed ?x)))
    :condition (and (at start (at ?x ?y)))
    :effect (and (at start (not (at ?x ?y))) (at end (at ?x ?z))))

  (:durative-action Load
    :parameters (?x - hoist ?y - crate ?z - truck ?p - place)
    :duration (= ?duration (/ (weight ?y) (power ?x)))
    :condition (and (over all (at ?x ?p)) (over all (at ?z ?p)))
    :effect (and (at end (not (lifting ?x ?y))) (at end (in ?y ?z)) (at end (available ?x))))

  (:durative-action Unload
    :parameters (?x - hoist ?y - crate ?z - truck ?p - place)
    :duration (= ?duration (/ (weight ?y) (power ?x)))
    :condition (and (over all (at ?x ?p)) (over all (at ?z ?p)) (at start (available ?x)) (at start (in ?y ?z)))
    :effect (and (at start (not (in ?y ?z))) (at start (not (available ?x)))))

  ; New action Lift
  (:durative-action Lift
    :parameters (?x - hoist ?y - crate ?z - surface ?p - place)
    :duration (= ?duration 1)
    :condition (and (at start (available ?x)) (at start (on ?y ?z)) (at start (at ?x ?p)))
    :effect (and (at start (not (available ?x))) (at start (not (on ?y ?z))) (at end (lifting ?x ?y))))

  ; New action Drop
  (:durative-action Drop
    :parameters (?x - hoist ?y - crate ?z - surface ?p - place)
    :duration (= ?duration 1)
    :condition (and (at start (lifting ?x ?y)) (at start (at ?x ?p)))
    :effect (and (at start (not (lifting ?x ?y))) (at end (on ?y ?z)) (at end (available ?x))))
)
