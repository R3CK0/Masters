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
               (clear ?y - surface)
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

  (:durative-action Lift
    :parameters (?x - hoist ?y - crate ?p - place ?s - surface)
    :duration (= ?duration 1)
    :condition (and (at start (at ?x ?p)) 
                    (at start (at ?y ?p)) 
                    (at start (available ?x)) 
                    (at start (clear ?y)) 
                    (at start (on ?y ?s)))
    :effect (and (at start (not (clear ?s))) 
                 (at start (lifting ?x ?y)) 
                 (at end (not (available ?x)))))

  (:durative-action Drop
    :parameters (?x - hoist ?y - crate ?p - place ?s - surface)
    :duration (= ?duration 1)
    :condition (and (at start (at ?x ?p))
                    (at start (at ?s ?p))
                    (at start (lifting ?x ?y))
                    (at start (clear ?s)))
    :effect (and (at start (not (lifting ?x ?y)))
                 (at end (on ?y ?s))
                 (at end (not (clear ?s)))
                 (at end (available ?x))
                 (at end (clear ?y)))))
