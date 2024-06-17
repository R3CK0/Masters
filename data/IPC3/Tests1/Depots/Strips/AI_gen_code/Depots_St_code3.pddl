(define (domain Depot)
  (:requirements :typing)
  (:types place locatable - object
    depot distributor - place
    truck hoist surface - locatable
    pallet crate - surface)

  ;; Predicates defined based on the code 
  (:predicates (at ?x - locatable ?y - place) 
               (on ?x - crate ?y - surface)
               (in ?x - crate ?y - truck)
               (available ?x - hoist)
               (clear ?x - surface)
               (lifting ?x - hoist ?y - crate))

  ;; 'Drive' action matches the provided executable code
  (:action Drive
    :parameters (?x - truck ?y - place ?z - place) 
    :precondition (and (at ?x ?y))
    :effect (and (not (at ?x ?y)) (at ?x ?z)))

  ;; 'Load' action matches the provided executable code
  (:action Load
    :parameters (?x - hoist ?y - crate ?z - truck ?p - place)
    :precondition (and (at ?x ?p) (at ?z ?p) (lifting ?x ?y))
    :effect (and (not (lifting ?x ?y)) (in ?y ?z) (available ?x)))

  ;; 'Unload' action matches the provided executable code
  (:action Unload 
    :parameters (?x - hoist ?y - crate ?z - truck ?p - place)
    :precondition (and (at ?x ?p) (at ?z ?p) (available ?x) (in ?y ?z))
    :effect (and (not (in ?y ?z)) (not (available ?x)) (lifting ?x ?y)))

  ;; Adding new actions for Lift and Drop
  (:action Lift
    :parameters (?x - hoist ?y - crate ?z - surface ?p - place)
    :precondition (and (at ?x ?p) (available ?x)
                       (at ?y ?p) (on ?y ?z) (clear ?y))
    :effect (and (not (available ?x)) (lifting ?x ?y)
                 (not (on ?y ?z)) (clear ?z) (not (clear ?y))))

  (:action Drop
    :parameters (?x - hoist ?y - crate ?z - surface ?p - place)
    :precondition (and (at ?x ?p) (lifting ?x ?y) (at ?z ?p) (clear ?z))
    :effect (and (not (lifting ?x ?y)) (available ?x)
                 (on ?y ?z) (not (clear ?z)) (clear ?y)))
)
