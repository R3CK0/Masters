(define (domain robotic-domain)
  (:requirements :adl :universal-preconditions)

  (:types
    location
    tool
    robot
    style
    dancing-teacher - tool
  )

  (:predicates
    (at ?r - robot ?l - location)
    (has ?r - robot ?t - tool)
    (movable ?t - tool)
    (tool-at ?t - tool ?l - location)
    (style-set ?s - style)
    (style-unset ?s - style)
  )

  (:action move_robot
    :parameters (?r - robot ?from - location ?to - location)
    :precondition (at ?r ?from)
    :effect (and (at ?r ?to)
                 (not (at ?r ?from)))
  )

  (:action move_robot_with_tool
    :parameters (?r - robot ?from - location ?to - location ?t - tool)
    :precondition (and (at ?r ?from) (has ?r ?t) (tool-at ?t ?from))
    :effect (and (at ?r ?to)
                 (not (at ?r ?from))
                 (tool-at ?t ?to)
                 (not (tool-at ?t ?from)))
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

  (:action USE_set_dancing_style
    :parameters (?r - robot ?s - style ?dt - dancing-teacher ?l - location)
    :precondition (and (at ?r ?l) (tool-at ?dt ?l)
                       (forall (?so - style) (style-unset ?so)))
    :effect (and (style-set ?s) (not (style-unset ?s)))
  )

  (:action USE_unset_dancing_style
    :parameters (?r - robot ?s - style ?dt - dancing-teacher ?l - location)
    :precondition (and (at ?r ?l) (tool-at ?dt ?l))
    :effect (and (not (style-set ?s)) (style-unset ?s))
  )
)
