(define (domain robotic-domain)
  (:requirements :fluents :strips :typing)

  (:types
    location
    state
    tool
    robot
  )

  (:predicates
    (at ?r - robot ?l - location)
    (has ?r - robot ?t - tool)
    (movable ?t - tool)
    (tool-at ?t - tool ?l - location)
  )

  (:action move_robot
    :parameters (?r - robot ?from - location ?to - location ?t - tool)
    :precondition (and (at ?r ?from)
                       (or (not (has ?r ?t)) (tool-at ?t ?from)))
    :effect (and (at ?r ?to)
                 (when (has ?r ?t) (tool-at ?t ?to)))
  )

  (:action pickup_object
    :parameters (?r - robot ?t - tool ?l - location)
    :precondition (and (at ?r ?l) (tool-at ?t ?l) (movable ?t))
    :effect (and (has ?r ?t) (not (tool-at ?t ?l)))
  )

  (:action drop_object
    :parameters (?r - robot ?t - tool ?l - location)
    :precondition (and (at ?r ?l) (has ?r ?t))
    :effect (and (not (has ?r ?t)) (tool-at ?t ?l))
  )

  (:action use_object
    :parameters (?r - robot ?t - tool ?l - location)
    :precondition (and (at ?r ?l) (has ?r ?t) (tool-at ?t ?l))
    :effect (and (has ?r ?t))
  )
)
