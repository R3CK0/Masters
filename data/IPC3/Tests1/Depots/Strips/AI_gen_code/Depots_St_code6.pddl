(define (domain Depot)
  (:requirements :typing)
  (:types 
    place locatable - object
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
    :precondition (and (at ?truck ?from))
    :effect (and (not (at ?truck ?from)) (at ?truck ?to))
  )

  (:action Lift
    :parameters (?hoist - hoist ?crate - crate ?surface - surface ?place - place)
    :precondition (and 
                    (at ?hoist ?place)
                    (available ?hoist)
                    (at ?crate ?place)
                    (on ?crate ?surface)
                    (clear ?crate))
    :effect (and 
              (not (available ?hoist))
              (lifting ?hoist ?crate)
              (clear ?surface)
              (not (clear ?crate))
              (not (on ?crate ?surface))
              (not (at ?crate ?place)))
  )

  (:action Drop
    :parameters (?hoist - hoist ?crate - crate ?surface - surface ?place - place)
    :precondition (and 
                    (at ?hoist ?place)
                    (lifting ?hoist ?crate)
                    (at ?surface ?place)
                    (clear ?surface))
    :effect (and 
              (available ?hoist)
              (not (lifting ?hoist ?crate))
              (at ?crate ?place)
              (on ?crate ?surface)
              (clear ?crate)
              (not (clear ?surface)))
  )

  (:action Load
    :parameters (?hoist - hoist ?crate - crate ?truck - truck ?place - place)
    :precondition (and 
                    (at ?hoist ?place)
                    (lifting ?hoist ?crate)
                    (at ?truck ?place))
    :effect (and 
              (not (lifting ?hoist ?crate))
              (not (available ?hoist))
              (not (at ?crate ?place))
              (in ?crate ?truck))
  )

  (:action Unload
    :parameters (?hoist - hoist ?crate - crate ?truck - truck ?place - place)
    :precondition (and 
                    (at ?hoist ?place)
                    (available ?hoist)
                    (in ?crate ?truck)
                    (at ?truck ?place))
    :effect (and 
              (lifting ?hoist ?crate)
              (not (available ?hoist))
              (at ?crate ?place)
              (not (in ?crate ?truck)))
  )
)
