(define (domain Depot)
  (:requirements :typing :fluents)
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
    (clear ?x - surface))

  (:functions 
    (load_limit ?t - truck) 
    (current_load ?t - truck) 
    (weight ?c - crate)
    (fuel-cost))

  ;; Drive action
  (:action drive
    :parameters (?t - truck ?from - place ?to - place)
    :precondition (at ?t ?from)
    :effect 
    (and (at ?t ?to) 
         (not (at ?t ?from))
         (increase (fuel-cost) 10)))

  ;; Lift action
  (:action lift
    :parameters (?h - hoist ?c - crate ?s - surface)
    :precondition (and (available ?h) (on ?c ?s) (clear ?c))
    :effect 
    (and (lifting ?h ?c)
         (not (on ?c ?s))
         (not (available ?h))
         (increase (fuel-cost) 1)))

  ;; Drop action
  (:action drop
    :parameters (?h - hoist ?c - crate ?s - surface)
    :precondition (and (lifting ?h ?c) (clear ?s))
    :effect 
    (and (available ?h) 
         (on ?c ?s)
         (not (lifting ?h ?c))))

  ;; Load action
  (:action load
    :parameters (?h - hoist ?c - crate ?t - truck)
    :precondition (and (lifting ?h ?c) 
                       (<= (+ (current_load ?t) (weight ?c)) (load_limit ?t)))
    :effect 
    (and (in ?c ?t)
         (not (lifting ?h ?c))
         (available ?h)
         (increase (current_load ?t) (weight ?c))))

  ;; Unload action
  (:action unload
    :parameters (?h - hoist ?c - crate ?t - truck ?s - surface)
    :precondition (and (available ?h) 
                       (in ?c ?t)
                       (clear ?s))
    :effect 
    (and (lifting ?h ?c)
         (not (in ?c ?t))
         (not (available ?h))
         (decrease (current_load ?t) (weight ?c))))
)
