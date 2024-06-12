(define (domain Depot)
  (:requirements :typing :durative-actions)
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

  (:durative-action Drive
    :parameters (?x - truck ?y - place ?z - place) 
    :duration (= ?duration 10)
    :condition (and (at start (at ?x ?y)))
    :effect (and (at start (not (at ?x ?y))) 
                 (at end (at ?x ?z))))

  (:durative-action Load
    :parameters (?h - hoist ?c - crate ?t - truck ?p - place)
    :duration (= ?duration 3)
    :condition (and (at start (at ?h ?p))
                    (at start (at ?t ?p))
                    (at start (lifting ?h ?c)))
    :effect (and (at start (not (lifting ?h ?c)))
                 (at start (available ?h))
                 (at end (in ?c ?t))
                 (increase (current_load ?t) (weight ?c))))

  (:durative-action Unload
    :parameters (?h - hoist ?c - crate ?t - truck ?p - place)
    :duration (= ?duration 4)
    :condition (and (at start (at ?h ?p))
                    (at start (at ?t ?p))
                    (at start (available ?h))
                    (at start (in ?c ?t)))
    :effect (and (at start (not (in ?c ?t)))
                 (at start (lifting ?h ?c))
                 (at start (not (available ?h)))))

  (:durative-action Lift
    :parameters (?h - hoist ?c - crate ?p - place ?s - surface)
    :duration (= ?duration 1)
    :condition (and (at start (at ?h ?p))
                    (at start (at ?c ?p))
                    (at start (on ?c ?s))
                    (at start (clear ?c))
                    (at start (available ?h)))
    :effect (and (at start (not (available ?h)))
                 (at start (lifting ?h ?c))
                 (at start (not (on ?c ?s)))
                 (at end (clear ?s))
                 (at end (not (clear ?c)))))

  (:durative-action Drop
    :parameters (?h - hoist ?c - crate ?p - place ?s - surface)
    :duration (= ?duration 1)
    :condition (and (at start (at ?h ?p))
                    (at start (at ?s ?p))
                    (at start (lifting ?h ?c))
                    (at start (clear ?s)))
    :effect (and (at start (not (lifting ?h ?c)))
                 (at end (available ?h))
                 (at end (on ?c ?s))
                 (at end (not (clear ?s)))
                 (at end (clear ?c))))
)
