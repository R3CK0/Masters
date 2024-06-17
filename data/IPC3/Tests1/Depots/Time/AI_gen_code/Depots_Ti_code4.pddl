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
             (lifting ?x - hoist ?y - crate)
             (clear ?x - surface) )

(:functions (distance ?x - place ?y - place)
            (speed ?t - truck)
            (weight ?c - crate)
            (power ?h - hoist))

(:durative-action Drive
    :parameters (?x - truck ?y - place ?z - place) 
    :duration (= ?duration (/ (distance ?y ?z) (speed ?x)))
    :condition (and (at start (at ?x ?y)))
    :effect (and (at start (not (at ?x ?y))) (at end (at ?x ?z))))

(:durative-action Lift
    :parameters (?x - hoist ?y - crate ?z - surface ?p - place)
    :duration (= ?duration (/ (weight ?y) (power ?x)))
    :condition (and (over all (at ?x ?p)) 
                    (at start (on ?y ?z))
                    (at start (clear ?y))
                    (over all (available ?x))
                    (over all (clear ?z)))
    :effect (and (at end (not (on ?y ?z))) 
                 (at end (not (clear ?y)))
                 (at end (lifting ?x ?y))
                 (at end (not (available ?x)))  
                 (at end (clear ?z))))

(:durative-action Drop
    :parameters (?x - hoist ?y - crate ?z - surface ?p - place)
    :duration (= ?duration (/ (weight ?y) (power ?x)))
    :condition (and (over all (at ?x ?p)) 
                    (over all (lifting ?x ?y))
                    (over all (clear ?z)))
    :effect (and (at end (on ?y ?z))
                 (at end (not (lifting ?x ?y)))
                 (at end (not (clear ?z)))
                 (at end (clear ?y)) 
                 (at end (available ?x))))

(:durative-action Load
    :parameters (?x - hoist ?y - crate ?z - truck ?p - place)
    :duration (= ?duration (/ (weight ?y) (power ?x)))
    :condition (and (over all (at ?x ?p)) 
                    (over all (at ?z ?p))
                    (over all (lifting ?x ?y)))
    :effect (and (at end (in ?y ?z))
                 (at end (not (lifting ?x ?y)))
                 (at end (available ?x))))

(:durative-action Unload 
    :parameters (?x - hoist ?y - crate ?z - truck ?p - place)
    :duration (= ?duration (/ (weight ?y) (power ?x)))
    :condition (and (over all (at ?x ?p)) 
                    (over all (at ?z ?p))
                    (at start (available ?x)) 
                    (at start (in ?y ?z)))
    :effect (and (at end (not (in ?y ?z))) 
                 (at end (lifting ?x ?y))
                 (at end (not (available ?x)))))
)
