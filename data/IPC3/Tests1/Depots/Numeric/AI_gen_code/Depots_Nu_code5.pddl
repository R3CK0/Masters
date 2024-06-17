(define (domain Depot)
(:requirements :typing :fluents)
(:types place locatable - object
    depot distributor - place
    truck hoist surface - locatable
    pallet crate - surface)

(:predicates 
    (at ?x - locatable ?y - place) 
    (on ?x - crate ?y - surface)
    (lifting ?x - hoist ?y - crate)
    (available ?x - hoist)
    (clear ?x - surface)
    (inside ?x - crate ?y - truck)
)

(:functions 
    (fuel-cost)
    (load ?x - truck)
    (load-limit ?x - truck)
    (weight ?x - crate)
)

(:action Drive
    :parameters (?t - truck ?p1 - place ?p2 - place)
    :precondition (at ?t ?p1)
    :effect (and (not (at ?t ?p1)) (at ?t ?p2) (increase (fuel-cost) 10)))

(:action Lift
    :parameters (?x - hoist ?y - crate ?z - surface ?p - place)
    :precondition (and (at ?x ?p) (available ?x) (at ?y ?p) (on ?y ?z) (clear ?y))
    :effect (and (not (at ?y ?p)) (lifting ?x ?y) (not (clear ?y)) (not (available ?x)) 
                 (clear ?z) (not (on ?y ?z)) (increase (fuel-cost) 1)))

(:action Drop 
    :parameters (?x - hoist ?y - crate ?z - surface ?p - place)
    :precondition (and (at ?x ?p) (at ?z ?p) (clear ?z) (lifting ?x ?y))
    :effect (and (available ?x) (not (lifting ?x ?y)) (at ?y ?p) (not (clear ?z)) (clear ?y)
        (on ?y ?z)))

(:action Load
    :parameters (?x - hoist ?y - crate ?t - truck ?p - place)
    :precondition (and (at ?x ?p) (lifting ?x ?y) (at ?t ?p) 
                    (<= (+ (load ?t) (weight ?y)) (load-limit ?t)))
    :effect (and (inside ?y ?t) (available ?x) (not (lifting ?x ?y))
                (increase (load ?t) (weight ?y))))

(:action Unload
    :parameters (?x - hoist ?y - crate ?t - truck ?p - place)
    :precondition (and (at ?x ?p) (available ?x) (inside ?y ?t) (at ?t ?p))
    :effect (and (not (inside ?y ?t)) (not (available ?x)) (lifting ?x ?y)
                (increase (load ?t) (- (weight ?y))))
))
