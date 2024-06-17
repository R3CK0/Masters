(define (domain Depot)
(:requirements :typing :durative-actions)
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

(:durative-action Drive
  :parameters (?x - truck ?y - place ?z - place)
  :duration (= ?duration 10)
  :condition (and (at start (at ?x ?y)))
  :effect (and (at start (not (at ?x ?y))) (at end (at ?x ?z))))

(:durative-action Lift
  :parameters (?h - hoist ?c - crate ?s - surface ?p - place)
  :duration (= ?duration 5)
  :condition (and (at start (at ?h ?p))
                  (at start (available ?h))
                  (at start (at ?c ?p))
                  (at start (on ?c ?s))
                  (at start (clear ?c)))
  :effect (and (at start (not (available ?h)))
               (at start (not (clear ?c)))
               (at start (lifting ?h ?c))
               (at end (not (on ?c ?s)))
               (at end (clear ?s))))

(:durative-action Drop
  :parameters (?h - hoist ?c - crate ?s - surface ?p - place)
  :duration (= ?duration 5)
  :condition (and (at start (at ?h ?p))
                  (at start (lifting ?h ?c))
                  (at start (at ?s ?p))
                  (at start (clear ?s)))
  :effect (and (at start (not (lifting ?h ?c)))
               (at start (available ?h))
               (at start (not (clear ?s)))
               (at end (on ?c ?s))
               (at end (clear ?c))))

(:durative-action Load
  :parameters (?h - hoist ?c - crate ?t - truck ?p - place)
  :duration (= ?duration 5)
  :condition (and (at start (at ?h ?p))
                  (at start (lifting ?h ?c))
                  (at start (at ?t ?p)))
  :effect (and (at start (not (lifting ?h ?c)))
               (at end (in ?c ?t))
               (at end (available ?h))))

(:durative-action Unload
  :parameters (?h - hoist ?c - crate ?t - truck ?p - place)
  :duration (= ?duration 5)
  :condition (and (at start (at ?h ?p))
                  (at start (available ?h))
                  (at start (in ?c ?t))
                  (at start (at ?t ?p)))
  :effect (and (at start (not (available ?h)))
               (at end (not (in ?c ?t)))
               (at end (lifting ?h ?c))))
)

