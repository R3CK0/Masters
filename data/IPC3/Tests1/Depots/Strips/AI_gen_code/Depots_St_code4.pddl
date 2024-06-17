(define (domain Depot)
  (:requirements :typing)
  (:types place locatable - object
          depot distributor - place
          truck hoist surface - locatable
          pallet crate - surface)

  (:predicates (at ?x - locatable ?y - place) 
               (on ?x - crate ?y - surface)
               (in ?x - crate ?y - truck)
               (lifting ?x - hoist ?y - crate)
               (available ?x - hoist)
               (clear ?x - surface))

  ;; Lift action
  (:action Lift
    :parameters (?x - hoist ?y - crate ?z - surface ?p - place)
    :precondition (and (at ?x ?p) (available ?x) (at ?y ?p) (on ?y ?z) (clear ?y))
    :effect (and (not (at ?y ?p)) (lifting ?x ?y) (not (clear ?y)) (not (available ?x)) 
                 (clear ?z) (not (on ?y ?z))))

  ;; Drop action
  (:action Drop 
    :parameters (?x - hoist ?y - crate ?z - surface ?p - place)
    :precondition (and (at ?x ?p) (at ?z ?p) (clear ?z) (lifting ?x ?y))
    :effect (and (available ?x) (not (lifting ?x ?y)) (at ?y ?p) (not (clear ?z)) (clear ?y)
                  (on ?y ?z)))

  ;; Drive action
  (:action Drive
    :parameters (?t - truck ?p1 - place ?p2 - place)
    :precondition (and (at ?t ?p1))
    :effect (and (not (at ?t ?p1)) (at ?t ?p2)))

  ;; Load action
  (:action Load
    :parameters (?x - hoist ?y - crate ?t - truck ?p - place)
    :precondition (and (at ?x ?p) (lifting ?x ?y) (at ?t ?p))
    :effect (and (not (lifting ?x ?y)) (in ?y ?t) (available ?x)))

  ;; Unload action
  (:action Unload
    :parameters (?x - hoist ?y - crate ?t - truck ?p - place)
    :precondition (and (at ?x ?p) (available ?x) (in ?y ?t) (at ?t ?p))
    :effect (and (lifting ?x ?y) (not (in ?y ?t)) (not (available ?x)))))

