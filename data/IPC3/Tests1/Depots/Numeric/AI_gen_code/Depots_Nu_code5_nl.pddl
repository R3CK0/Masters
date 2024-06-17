(define (domain Depot)
  (:requirements :typing :fluents)
  (:types place locatable - object
          depot distributor - place
          truck hoist surface - locatable
          pallet crate - surface)

  (:predicates (at ?x - locatable ?y - place) 
               (on ?x - crate ?y - surface)
               (lifting ?x - hoist ?y - crate)
               (available ?x - hoist)
               (clear ?x - surface)
               (in ?x - crate ?y - truck)
  )

  (:functions 
    (fuel-cost)
    (load_limit ?t - truck)
    (current_load ?t - truck)
    (weight ?c - crate)
  )
  
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
                      (<= (+ (current_load ?t) (weight ?y)) (load_limit ?t)))
    :effect (and (in ?y ?t) (not (lifting ?x ?y)) (available ?x) 
                 (increase (current_load ?t) (weight ?y))))
  
  (:action Unload
    :parameters (?x - hoist ?y - crate ?t - truck ?p - place)
    :precondition (and (at ?x ?p) (available ?x) (in ?y ?t) (at ?t ?p))
    :effect (and (lifting ?x ?y) (not (in ?y ?t)) (not (available ?x)) 
                 (decrease (current_load ?t) (weight ?y))))
  
  (:action Drive
    :parameters (?t - truck ?p1 - place ?p2 - place)
    :precondition (at ?t ?p1)
    :effect (and (at ?t ?p2) (not (at ?t ?p1)) (increase (fuel-cost) 10)))
)

