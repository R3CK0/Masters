(define (domain Depot)
  (:requirements :typing :durative-actions :fluents)
  (:types place locatable - object
          depot distributor - place
          truck hoist surface - locatable
          pallet crate - surface)

  (:predicates
    (at ?x - locatable ?y - place)
    (on ?x - crate ?y - surface)
    (inside ?x - crate ?y - truck)
    (lifting ?x - hoist ?y - crate)
    (available ?x - hoist)
    (clear ?x - surface)
  )
  
  (:durative-action Lift
    :parameters (?x - hoist ?y - crate ?z - surface ?p - place)
    :duration (= ?duration 1)
    :condition (and (over all (at ?x ?p))
                    (at start (available ?x))
                    (at start (at ?y ?p))
                    (at start (on ?y ?z))
                    (at start (clear ?y)))
    :effect (and (at start (not (at ?y ?p)))
                 (at start (lifting ?x ?y))
                 (at start (not (clear ?y)))
                 (at start (not (available ?x)))
                 (at start (clear ?z))
                 (at start (not (on ?y ?z))))
  )

  (:durative-action Drop
    :parameters (?x - hoist ?y - crate ?z - surface ?p - place)
    :duration (= ?duration 1)
    :condition (and (over all (at ?x ?p))
                    (over all (at ?z ?p))
                    (over all (clear ?z))
                    (over all (lifting ?x ?y)))
    :effect (and (at end (available ?x))
                 (at end (not (lifting ?x ?y)))
                 (at end (at ?y ?p))
                 (at end (not (clear ?z)))
                 (at end (clear ?y))
                 (at end (on ?y ?z)))
  )

  (:durative-action Drive
    :parameters (?t - truck ?p1 ?p2 - place)
    :duration (= ?duration 1)
    :condition (and (at start (at ?t ?p1)))
    :effect (and (at end (not (at ?t ?p1)))
                 (at end (at ?t ?p2)))
  )

  (:durative-action Load
    :parameters (?x - hoist ?y - crate ?t - truck ?p - place)
    :duration (= ?duration 1)
    :condition (and (over all (at ?x ?p))
                    (over all (at ?t ?p))
                    (over all (lifting ?x ?y)))
    :effect (and (at end (inside ?y ?t))
                 (at end (not (lifting ?x ?y)))
                 (at end (available ?x)))
  )

  (:durative-action Unload
    :parameters (?x - hoist ?y - crate ?t - truck ?p - place)
    :duration (= ?duration 1)
    :condition (and (over all (at ?x ?p))
                    (over all (at ?t ?p))
                    (at start (inside ?y ?t))
                    (at start (available ?x)))
    :effect (and (at end (not (inside ?y ?t)))
                 (at end (lifting ?x ?y))
                 (at end (not (available ?x))))
  )
)
