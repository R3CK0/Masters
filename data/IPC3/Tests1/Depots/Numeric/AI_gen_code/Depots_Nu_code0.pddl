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
               (clear ?x - surface ?y - place))  ;; Clear now requires both surface and place context

  (:functions  
    (fuel-cost)
    (load ?x - truck)  ;; To track the truck load
    (weight ?x - crate)  ;; Weight of each crate
    (load-limit ?x - truck)  ;; Load limit for each truck
  )
  
  ;; Drive action
  (:action Drive
    :parameters (?x - truck ?y - place ?z - place) 
    :precondition (and (at ?x ?y))
    :effect (and (not (at ?x ?y)) (at ?x ?z)
                 (increase (fuel-cost) 10)))

  ;; Lift action
  (:action Lift
    :parameters (?x - hoist ?y - crate ?z - surface ?p - place)
    :precondition (and (at ?x ?p) (available ?x) (at ?y ?p) (on ?y ?z) (clear ?y ?p))
    :effect (and (not (at ?y ?p)) (lifting ?x ?y) (not (clear ?y ?p)) (not (available ?x)) 
                 (clear ?z ?p) (not (on ?y ?z)) (increase (fuel-cost) 1)))

  ;; Drop action
  (:action Drop 
    :parameters (?x - hoist ?y - crate ?z - surface ?p - place)
    :precondition (and (at ?x ?p) (at ?z ?p) (clear ?z ?p) (lifting ?x ?y))
    :effect (and (available ?x) (not (lifting ?x ?y)) (at ?y ?p) (not (clear ?z ?p)) (clear ?y ?p)
                  (on ?y ?z)))

  ;; Load action
  (:action Load
    :parameters (?x - hoist ?y - crate ?z - truck ?p - place)
    :precondition (and (at ?x ?p) (at ?z ?p) (lifting ?x ?y)
                        (<= (+ (load ?z) (weight ?y)) (load-limit ?z)))
    :effect (and (not (lifting ?x ?y)) (in ?y ?z) (available ?x)
          (increase (load ?z) (weight ?y))))

  ;; Unload action
  (:action Unload 
    :parameters (?x - hoist ?y - crate ?z - truck ?p - place)
    :precondition (and (at ?x ?p) (at ?z ?p) (available ?x) (in ?y ?z))
    :effect (and (not (in ?y ?z)) (not (available ?x)) (lifting ?x ?y)
          (decrease (load ?z) (weight ?y)))))

