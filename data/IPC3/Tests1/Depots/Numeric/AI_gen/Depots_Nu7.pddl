(define (domain Depot)
    (:requirements :typing :fluents)
    (:types place locatable - object
	    depot distributor - place
        truck hoist surface - locatable
        pallet crate - surface)
    
    (:predicates 
        (at ?x - locatable ?y - place) 
        (on ?x - crate ?y - surface)
        (in ?x - crate ?y - truck)
        (lifting ?x - hoist ?y - crate)
        (available ?x - hoist)
        (clear ?x - surface)
    )

    (:functions 
        (load_limit ?t - truck) 
        (current_load ?t - truck) 
        (weight ?c - crate)
        (fuel-cost)
    )

    ;; Action: Drive
    (:action drive
        :parameters (?t - truck ?from ?to - place)
        :precondition (and (at ?t ?from))
        :effect (and (not (at ?t ?from))
                     (at ?t ?to)
                     (increase (fuel-cost) 10))
    )

    ;; Action: Load
    (:action load
        :parameters (?h - hoist ?c - crate ?t - truck ?p - place)
        :precondition (and (at ?h ?p)
                           (at ?t ?p)
                           (lifting ?h ?c)
                           (<= (+ (current_load ?t) (weight ?c))
                               (load_limit ?t)))
        :effect (and (not (lifting ?h ?c))
                     (available ?h)
                     (in ?c ?t)
                     (increase (current_load ?t) (weight ?c)))
    )

    ;; Action: Unload
    (:action unload
        :parameters (?h - hoist ?c - crate ?t - truck ?p - place)
        :precondition (and (at ?h ?p)
                           (at ?t ?p)
                           (available ?h)
                           (in ?c ?t))
        :effect (and (not (in ?c ?t))
                     (lifting ?h ?c)
                     (not (available ?h))
                     (decrease (current_load ?t) (weight ?c)))
    )

    ;; Action: Lift
    (:action lift
        :parameters (?h - hoist ?c - crate ?p - place ?s - surface)
        :precondition (and (at ?h ?p)
                           (at ?c ?p)
                           (on ?c ?s)
                           (clear ?c)
                           (available ?h))
        :effect (and (not (on ?c ?s))
                     (lifting ?h ?c)
                     (not (available ?h))
                     (not (clear ?c))
                     (increase (fuel-cost) 1))
    )

    ;; Action: Drop
    (:action drop
        :parameters (?h - hoist ?c - crate ?p - place ?s - surface)
        :precondition (and (at ?h ?p)
                           (at ?s ?p)
                           (lifting ?h ?c)
                           (clear ?s))
        :effect (and (not (lifting ?h ?c))
                     (on ?c ?s)
                     (available ?h)
                     (not (clear ?s))
                     (clear ?c))
    )
)
