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
    :parameters (?truck - truck ?place1 - place ?place2 - place)
    :duration (= ?duration (/ (distance ?place1 ?place2) (speed ?truck)))
    :condition (and (at start (at ?truck ?place1)))
    :effect (and (at end (at ?truck ?place2))
                 (at end (not (at ?truck ?place1)))))

(:durative-action Lift
    :parameters (?hoist - hoist ?crate - crate ?surface - surface ?place - place)
    :duration (= ?duration (/ (weight ?crate) (power ?hoist))) ; Custom duration based on crate weight and hoist power
    :condition (and (at start (at ?hoist ?place))
                    (at start (available ?hoist))
                    (at start (at ?crate ?place))
                    (at start (on ?crate ?surface))
                    (at start (clear ?crate)))
    :effect (and (at end (lifting ?hoist ?crate))
                 (at end (clear ?surface))
                 (at end (not (on ?crate ?surface)))
                 (at end (not (clear ?crate)))
                 (at end (not (available ?hoist))
                 (at end (not (at ?crate ?place))))))

(:durative-action Drop
    :parameters (?hoist - hoist ?crate - crate ?surface - surface ?place - place)
    :duration (= ?duration 1)
    :condition (and (at start (at ?hoist ?place))
                    (at start (lifting ?hoist ?crate))
                    (at start (at ?surface ?place))
                    (at start (clear ?surface)))
    :effect (and (at end (not (lifting ?hoist ?crate)))
                 (at end (available ?hoist))
                 (at end (at ?crate ?place))
                 (at end (on ?crate ?surface))
                 (at end (clear ?crate))
                 (at end (not (clear ?surface)))))

(:durative-action Load
    :parameters (?hoist - hoist ?crate - crate ?truck - truck ?place - place)
    :duration (= ?duration 1)
    :condition (and (at start (at ?hoist ?place))
                    (at start (lifting ?hoist ?crate))
                    (at start (at ?truck ?place)))
    :effect (and (at end (in ?crate ?truck))
                 (at end (not (lifting ?hoist ?crate)))
                 (at end (available ?hoist))))

(:durative-action Unload
    :parameters (?hoist - hoist ?crate - crate ?truck - truck ?place - place)
    :duration (= ?duration 1)
    :condition (and (at start (at ?hoist ?place))
                    (at start (available ?hoist))
                    (at start (in ?crate ?truck))
                    (at start (at ?truck ?place)))
    :effect (and (at end (lifting ?hoist ?crate))
                 (at end (not (in ?crate ?truck)))
                 (at end (not (available ?hoist)))))
)
