;added fuel-tank fuel-available current-fuel distance and modified Drive function 

(define (domain Depot)
(:requirements :typing :fluents)
(:types place locatable - object
	depot distributor - place
    truck hoist surface - locatable
    pallet crate - surface)

(:predicates (at ?x - locatable ?y - place) 
             (on ?x - crate ?y - surface)
             (in ?x - crate ?y - truck)
             (lifting ?x - hoist ?y - crate)
             (available ?x - hoist)
             (clear ?x - surface)
             (fuel-available ?x - truck) ; predicate indicating if the truck has fuel
)

(:functions 
	(load_limit ?t - truck) 
	(current_load ?t - truck) 
	(weight ?c - crate)
	(fuel-cost)
    (fuel-tank ?t - truck) ; maximum fuel capacity of the truck
    (current-fuel ?t - truck) ; current fuel level of the truck
    (distance ?y ?z - place) ; distance between places
)

(:action Drive
:parameters (?x - truck ?y - place ?z - place) 
:precondition (and (at ?x ?y) (>= (current-fuel ?x) (* (distance ?y ?z) (+ 1 (current_load ?x)))))
:effect (and (not (at ?x ?y)) (at ?x ?z)
             (decrease (current-fuel ?x) (* (distance ?y ?z) (+ 1 (current_load ?x))))
             (increase (fuel-cost) (* (distance ?y ?z) (+ 1 (current_load ?x))))))

(:action Refuel
:parameters (?x - truck ?p - place)
:precondition (at ?x ?p)
:effect (assign (current-fuel ?x) (fuel-tank ?x)))

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
:parameters (?x - hoist ?y - crate ?z - truck ?p - place)
:precondition (and (at ?x ?p) (at ?z ?p) (lifting ?x ?y)
		(<= (+ (current_load ?z) (weight ?y)) (load_limit ?z)))
:effect (and (not (lifting ?x ?y)) (in ?y ?z) (available ?x)
		(increase (current_load ?z) (weight ?y))))

(:action Unload 
:parameters (?x - hoist ?y - crate ?z - truck ?p - place)
:precondition (and (at ?x ?p) (at ?z ?p) (available ?x) (in ?y ?z))
:effect (and (not (in ?y ?z)) (not (available ?x)) (lifting ?x ?y)
		(decrease (current_load ?z) (weight ?y))))

)

