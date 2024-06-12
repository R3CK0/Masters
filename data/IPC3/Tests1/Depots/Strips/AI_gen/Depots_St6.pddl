(define (domain Depot)

(:requirements :typing)
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

(:action Drive
    :parameters (?truck - truck ?from - place ?to - place)
    :precondition (at ?truck ?from)
    :effect (and 
        (not (at ?truck ?from))
        (at ?truck ?to)
    )
)

(:action Load
    :parameters (?hoist - hoist ?truck - truck ?crate - crate ?place - place)
    :precondition (and 
        (at ?hoist ?place)
        (at ?truck ?place)
        (lifting ?hoist ?crate)
    )
    :effect (and 
        (not (lifting ?hoist ?crate))
        (available ?hoist)
        (in ?crate ?truck)
    )
)

(:action Unload
    :parameters (?hoist - hoist ?truck - truck ?crate - crate ?place - place)
    :precondition (and 
        (at ?hoist ?place)
        (at ?truck ?place)
        (available ?hoist)
        (in ?crate ?truck)
    )
    :effect (and 
        (not (in ?crate ?truck))
        (lifting ?hoist ?crate)
        (not (available ?hoist))
    )
)

(:action Lift
    :parameters (?hoist - hoist ?crate - crate ?surface - surface ?place - place)
    :precondition (and 
        (at ?hoist ?place)
        (at ?crate ?place)
        (at ?surface ?place)
        (available ?hoist)
        (clear ?crate)
        (on ?crate ?surface)
    )
    :effect (and 
        (lifting ?hoist ?crate)
        (not (available ?hoist))
        (not (at ?crate ?place))
        (clear ?surface)
        (not (clear ?crate))
    )
)

(:action Drop
    :parameters (?hoist - hoist ?crate - crate ?surface - surface ?place - place)
    :precondition (and 
        (at ?hoist ?place)
        (at ?surface ?place)
        (lifting ?hoist ?crate)
        (clear ?surface)
    )
    :effect (and 
        (on ?crate ?surface)
        (available ?hoist)
        (clear ?crate)
        (not (lifting ?hoist ?crate))
        (not (clear ?surface))
        (at ?crate ?place)
    )
)

)
