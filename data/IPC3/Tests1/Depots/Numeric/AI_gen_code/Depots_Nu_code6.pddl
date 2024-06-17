(define (domain Depot)
(:requirements :typing :fluents)
(:types place locatable - object
	depot distributor - place
        truck hoist surface - locatable
        pallet crate - surface)

(:predicates (at ?x - locatable ?y - place) 
             (on ?x - crate ?y - surface)
             (in ?x - crate ?y - truck)
             (available ?x - hoist)
             (clear ?x - surface)
             (lifting ?x - hoist ?y - crate)
)

(:functions 
	(fuel-cost)
)

;; Drive action
(:action Drive
  :parameters (?x - truck ?y - place ?z - place) 
  :precondition (at ?x ?y)
  :effect (and (not (at ?x ?y)) (at ?x ?z)
                 (increase (fuel-cost) 10)))

;; Lift action
(:action Lift
  :parameters (?h - hoist ?c - crate ?s - surface ?p - place)
  :precondition (and (at ?h ?p)
                     (available ?h)
                     (at ?c ?p)
                     (on ?c ?s)
                     (clear ?c))
  :effect (and (not (on ?c ?s))
               (not (clear ?c))
               (clear ?s)
               (available ?h)
               (lifting ?h ?c)
               (increase (fuel-cost) 1)))

;; Drop action
(:action Drop
  :parameters (?h - hoist ?c - crate ?s - surface ?p - place)
  :precondition (and (at ?h ?p)
                     (lifting ?h ?c)
                     (at ?s ?p)
                     (clear ?s))
  :effect (and (not (lifting ?h ?c))
               (available ?h)
               (on ?c ?s)
               (clear ?c)
               (not (clear ?s))))

;; Load action
(:action Load
  :parameters (?h - hoist ?c - crate ?t - truck ?p - place)
  :precondition (and (at ?h ?p)
                     (lifting ?h ?c)
                     (at ?t ?p))
  :effect (and (not (lifting ?h ?c))
               (available ?h)
               (in ?c ?t)
               (increase (fuel-cost) 1))) ;; assuming some fuel cost as per code logic

;; Unload action
(:action Unload
  :parameters (?h - hoist ?c - crate ?t - truck ?p - place)
  :precondition (and (at ?h ?p)
                     (available ?h)
                     (in ?c ?t)
                     (at ?t ?p))
  :effect (and (not (in ?c ?t))
               (lifting ?h ?c)
               (increase (fuel-cost) 1)))) ;; assuming some fuel cost as per code logic
