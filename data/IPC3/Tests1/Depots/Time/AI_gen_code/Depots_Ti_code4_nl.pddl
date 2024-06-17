(define (domain Depot)
    (:requirements :typing :durative-actions :fluents)
    (:types place locatable - object
        depot distributor - place
        truck hoist surface - locatable
        pallet crate - surface)

    (:predicates (at ?x - locatable ?y - place) 
                 (on ?x - crate ?y - surface)
                 (in ?x - crate ?y - truck)
                 (clear ?x - surface)
                 (lifting ?x - hoist ?y - crate)
                 (available ?x - hoist))

    (:functions (distance ?x - place ?y - place)
                (speed ?t - truck)
                (weight ?c - crate)
                (power ?h - hoist))

    (:durative-action Drive
        :parameters (?t - truck ?from - place ?to - place) 
        :duration (= ?duration (/ (distance ?from ?to) (speed ?t)))
        :condition (and (at start (at ?t ?from)))
        :effect (and (at start (not (at ?t ?from))) (at end (at ?t ?to))))

    (:durative-action Load
        :parameters (?h - hoist ?c - crate ?t - truck ?p - place)
        :duration (= ?duration (/ (weight ?c) (power ?h)))
        :condition (and (over all (at ?h ?p)) 
                        (over all (at ?t ?p))
                        (at start (lifting ?h ?c)))
        :effect (and (at end (not (lifting ?h ?c))) 
                     (at end (in ?c ?t))
                     (at end (available ?h))))

    (:durative-action Unload
        :parameters (?h - hoist ?c - crate ?t - truck ?p - place)
        :duration (= ?duration (/ (weight ?c) (power ?h)))
        :condition (and (over all (at ?h ?p))
                        (over all (at ?t ?p))
                        (at start (in ?c ?t))
                        (at start (available ?h)))
        :effect (and (at start (not (in ?c ?t)))
                     (at end (lifting ?h ?c))
                     (at end (available ?h) (clear ?h) (at ?c ?p))))

    (:durative-action Lift
        :parameters (?h - hoist ?c - crate ?s - surface ?p - place)
        :duration (= ?duration 1)
        :condition (and (at start (at ?h ?p))
                        (at start (available ?h))
                        (at start (at ?c ?p))
                        (at start (on ?c ?s))
                        (at start (clear ?c)))
        :effect (and (at start (not (on ?c ?s)))
                     (at start (not (clear ?s)))
                     (at end (lifting ?h ?c))
                     (at end (available ?h))))

    (:durative-action Drop
        :parameters (?h - hoist ?c - crate ?s - surface ?p - place)
        :duration (= ?duration 1)
        :condition (and (at start (at ?h ?p))
                        (at start (lifting ?h ?c))
                        (at start (at ?s ?p))
                        (at end (clear ?s)))
        :effect (and (at start (not (lifting ?h ?c)))
                     (at start (available ?h))
                     (at end (on ?c ?s))
                     (at end (clear ?h))
                     (at end (clear ?c))))
)
