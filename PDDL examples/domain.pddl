(define (domain agent-domain)
  (:requirements :fluents :strips :typing :negative-preconditions)

  (:types
    location
    tool
    agent
    store banana bank - tool  ; Treat banana as a type of tool for interaction purposes
  )

  (:predicates
    (at ?a - agent ?l - location)
    (has ?a - agent ?t - tool)
    (movable ?t - tool)
    (tool-at ?t - tool ?l - location)  ; Predicate to track the hunger state of the agent
    (empty ?a - agent)  ; Predicate to track if the agent is carrying anything
  )

  (:functions  ; Define hunger as a fluent (0 for false, 1 for true)
    (credits)
    (hunger)  ; Define credits as a fluent (range 0-100)
  )

  (:action move_agent
    :parameters (?a - agent ?from ?to - location)
    :precondition (and (at ?a ?from) (empty ?a))
    :effect (and (at ?a ?to)
                 (not (at ?a ?from)))
  )

  (:action move_agent_with_tool
    :parameters (?a - agent ?from ?to - location ?t - tool)
    :precondition (and (at ?a ?from) (has ?a ?t) (tool-at ?t ?from))
    :effect (and (at ?a ?to)
                 (not (at ?a ?from))
                 (tool-at ?t ?to)
                 (not (tool-at ?t ?from)))
  )

  (:action pickup_object
    :parameters (?a - agent ?t - tool ?l - location)
    :precondition (and (at ?a ?l) (tool-at ?t ?l) (movable ?t) (empty ?a))
    :effect (and (has ?a ?t) (not (tool-at ?t ?l)) (not (empty ?a)))
  )

  (:action drop_object
    :parameters (?a - agent ?t - tool ?l - location)
    :precondition (and (at ?a ?l) (has ?a ?t))
    :effect (and (not (has ?a ?t)) (tool-at ?t ?l) (empty ?a))
  )

  (:action use_banana
    :parameters (?a - agent ?b - banana ?l - location)
    :precondition (and (at ?a ?l) (has ?a ?b))
    :effect (and (assign (hunger) 0) (not (has ?a ?b)))
  )

  (:action USE_store
    :parameters (?a - agent ?s - store ?l - location ?b - banana)
    :precondition (and (at ?a ?l) (tool-at ?s ?l) (>= (credits) 5))
    :effect (and (decrease (credits) 5)
                 (tool-at ?b ?l))
  )

  (:action USE_bank
    :parameters (?a - agent ?b - bank ?l - location)
    :precondition (and (at ?a ?l) (tool-at ?b ?l))
    :effect (and (increase (credits) 3))
  )
)