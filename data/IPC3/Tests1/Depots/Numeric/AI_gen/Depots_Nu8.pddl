(define (domain Depot)
    (:requirements :typing :fluents)
    (:types 
        place locatable - object
        depot distributor - place
        truck hoist surface - locatable
        pallet crate - surface
    )

    (:predicates 
        (at ?x - locatable ?y - place) 
        (on ?x - crate ?y - surface)
        (in ?x - crate ?y - truck)
        (lifting ?x - hoist ?y - crate)
        (available ?x - hoist)
        (clear ?s - surface)  ;; New predicate definition
    )

    (:functions 
        (load_limit ?t - truck) 
        (current_load ?t - truck) 
        (weight ?c - crate)
        (fuel-cost)
    )
    
    (:action Drive
        :parameters (?x - truck ?y - place ?z - place) 
        :precondition (and (at ?x ?y))
        :effect (and (not (at ?x ?y)) (at ?x ?z)
            (increase (fuel-cost) 10)))

    (:action Lift
        :parameters (?x - hoist ?y - crate ?z - surface ?p - place)
        :precondition (and 
            (at ?x ?p) 
            (available ?x) 
            (at ?y ?p) 
            (on ?y ?z) 
            (clear ?y)  ;; Check if the crate is clear
        )
        :effect (and 
            (not (at ?y ?p)) 
            (lifting ?x ?y) 
            (not (available ?x)) 
            (not (on ?y ?z)) 
            (clear ?z)  ;; Original surface becomes clear
            (not (clear ?y)) ;; Crate itself is no longer clear
            (increase (fuel-cost) 1)
        )
    )

    (:action Drop 
        :parameters (?x - hoist ?y - crate ?z - surface ?p - place)
        :precondition (and 
            (at ?x ?p) 
            (at ?z ?p) 
            (lifting ?x ?y)
            (clear ?z)  ;; Check if the surface is clear
        )
        :effect (and 
            (available ?x) 
            (not (lifting ?x ?y)) 
            (at ?y ?p) 
            (on ?y ?z)
            (not (clear ?z)) ;; Surface is no longer clear
            (clear ?y)  ;; Crate on the surface is clear
        )
    )

    (:action Load
        :parameters (?x - hoist ?y - crate ?z - truck ?p - place)
        :precondition (and 
            (at ?x ?p) 
            (at ?z ?p) 
            (lifting ?x ?y)
            (<= (+ (current_load ?z) (weight ?y)) (load_limit ?z))
        )
        :effect (and 
            (not (lifting ?x ?y)) 
            (in ?y ?z) 
            (available ?x)
            (increase (current_load ?z) (weight ?y))
        )
    )

    (:action Unload 
        :parameters (?x - hoist ?y - crate ?z - truck ?p - place)
        :precondition (and 
            (at ?x ?p) 
            (at ?z ?p) 
            (available ?x) 
            (in ?y ?z)
        )
        :effect (and 
            (not (in ?y ?z)) 
            (not (available ?x)) 
            (lifting ?x ?y)
            (decrease (current_load ?z) (weight ?y))
        )
    )
)
