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

  (:durative-action Lift
    :parameters (?x - hoist ?y - crate ?z - surface ?p - place)
    :duration (= ?duration 1)
    :condition (and (over all (at ?x ?p)) (at start (available ?x)) (at start (at ?y ?p)) (at start (on ?y ?z)) (at start (clear ?y)))
    :effect (and (at start (not (at ?y ?p))) (at start (lifting ?x ?y)) (at start (not (clear ?y))) (at start (not (available ?x))) 
                 (at start (clear ?z)) (at start (not (on ?y ?z)))))

  (:durative-action Drop 
    :parameters (?x - hoist ?y - crate ?z - surface ?p - place)
    :duration (= ?duration 1)
    :condition (and (over all (at ?x ?p)) (over all (at ?z ?p)) (over all (clear ?z)) (over all (lifting ?x ?y)))
    :effect (and (at end (available ?x)) (at end (not (lifting ?x ?y))) (at end (at ?y ?p)) (at end (not (clear ?z))) (at end (clear ?y))
                  (at end (on ?y ?z))))

  (:durative-action Load
    :parameters (?h - hoist ?c - crate ?t - truck ?p - place)
    :duration (= ?duration (/ (weight ?c) (power ?h)))
    :condition (and (over all (at ?t ?p)) (at start (lifting ?h ?c)) (at start (available ?h)))
    :effect (and (at start (not (lifting ?h ?c))) (at end (in ?c ?t)) (at start (not (available ?h))) ))

  (:durative-action Unload
    :parameters (?h - hoist ?c - crate ?t - truck ?p - place ?z - surface)
    :duration (= ?duration (/ (weight ?c) (power ?h)))
    :condition (and (over all (at ?t ?p)) (at start (in ?c ?t)) (at start (available ?h)) (at start (clear ?z)))
    :effect (and (at end (lifting ?h ?c)) (at end (on ?c ?z)) (at start (not (in ?c ?t))) (at end (available ?h)) ))

  (:durative-action Drive
    :parameters (?t - truck ?from - place ?to - place)
    :duration (= ?duration (/ (distance ?from ?to) (speed ?t)))
    :condition (at start (at ?t ?from))
    :effect (and (at start (not (at ?t ?from))) (at end (at ?t ?to))))
)
