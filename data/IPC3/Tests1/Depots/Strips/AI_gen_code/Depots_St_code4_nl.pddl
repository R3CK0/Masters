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

(:action Lift
  :parameters (?x - hoist ?y - crate ?z - surface ?p - place)
  :precondition (and (at ?x ?p) (available ?x) (at ?y ?p) (on ?y ?z) (clear ?y))
  :effect (and (not (at ?y ?p)) (lifting ?x ?y) (not (clear ?y)) (not (available ?x)) 
               (clear ?z) (not (on ?y ?z))))

(:action Drop 
  :parameters (?x - hoist ?y - crate ?z - surface ?p - place)
  :precondition (and (at ?x ?p) (at ?z ?p) (clear ?z) (lifting ?x ?y))
  :effect (and (available ?x) (not (lifting ?x ?y)) (at ?y ?p) (not (clear ?z)) (clear ?y)
                (on ?y ?z)))
)
