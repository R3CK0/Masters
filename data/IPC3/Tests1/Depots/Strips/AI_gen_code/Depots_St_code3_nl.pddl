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
        (available ?x - hoist)
        (clear ?x - surface)
        (lifting ?x - hoist ?y - crate))
        
    ; Drive action moves the truck from one place to another
    (:action Drive
        :parameters (?x - truck ?y - place ?z - place) 
        :precondition (and (at ?x ?y))
        :effect (and (not (at ?x ?y)) (at ?x ?z)))

    ; Lift action uses the hoist to lift a crate from a surface
    (:action Lift
        :parameters (?x - hoist ?y - crate ?z - surface ?p - place)
        :precondition (and (at ?x ?p) (available ?x) (at ?y ?p) (on ?y ?z) (clear ?y) (clear ?z))
        :effect (and (not (clear ?y)) (not (on ?y ?z)) (lifting ?x ?y) (not (clear ?z)) (not (available ?x))))

    ; Drop action uses the hoist to put down a crate on a surface
    (:action Drop
        :parameters (?x - hoist ?y - crate ?z - surface ?p - place)
        :precondition (and (at ?x ?p) (lifting ?x ?y) (clear ?z) (at ?z ?p))
        :effect (and (on ?y ?z) (clear ?y) (available ?x) (clear ?z) (not (lifting ?x ?y))))
        
    ; Load action loads the crate currently on the hoist into the truck
    (:action Load
        :parameters (?x - hoist ?y - crate ?z - truck ?p - place)
        :precondition (and (at ?x ?p) (at ?z ?p) (lifting ?x ?y))
        :effect (and (not (lifting ?x ?y)) (in ?y ?z) (available ?x)))
    
    ; Unload action unloads the crate from the truck using the hoist
    (:action Unload 
        :parameters (?x - hoist ?y - crate ?z - truck ?p - place)
        :precondition (and (at ?x ?p) (at ?z ?p) (available ?x) (in ?y ?z))
        :effect (and (not (in ?y ?z)) (not (available ?x)) (lifting ?x ?y)))
)

