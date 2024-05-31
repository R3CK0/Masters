(define (domain initial-domain)
  (:requirements :fluents :strips :typing)

  (:types
    location
    tool
    agent
  )

  (:predicates
    (at ?a - agent ?l - location)
    (has ?a - agent ?t - tool)
    (movable ?t - tool)
    (tool-at ?t - tool ?l - location)
    (reachable ?l - location)
    (tool-reachable ?t - tool)
    (valid-location ?t - tool ?l - location)
  )

  (:action move_agent
    :parameters (?a - agent ?from - location ?to - location)
    :precondition (and (at ?a ?from) (reachable ?to))
    :effect (and (at ?a ?to)
                 (not (at ?a ?from)))
  )

  (:action move_agent_with_tool
    :parameters (?a - agent ?from - location ?to - location ?t - tool)
    :precondition (and (at ?a ?from) (has ?a ?t) (tool-at ?t ?from) (reachable ?to))
    :effect (and (at ?a ?to)
                 (not (at ?a ?from))
                 (tool-at ?t ?to)
                 (not (tool-at ?t ?from)))
  )

  (:action pickup_object
    :parameters (?a - agent ?t - tool ?l - location)
    :precondition (and (at ?a ?l) (tool-at ?t ?l) (movable ?t) (tool-reachable ?t))
    :effect (and (has ?a ?t) (not (tool-at ?t ?l)))
  )

  (:action drop_object
    :parameters (?a - agent ?t - tool ?l - location)
    :precondition (and (at ?a ?l) (has ?a ?t))
    :effect (and (not (has ?a ?t)) (tool-at ?t ?l))
  )
)
