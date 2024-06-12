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
 :parameters (?h - hoist ?c - crate ?s - surface)
 :duration (= ?duration 1)
 :condition (and (at start (clear ?c))
                 (at start (on ?c ?s))
                 (at start (available ?h)))
 :effect (and (at start (not (on ?c ?s)))
              (at start (not (available ?h)))
              (at end (lifting ?h ?c))))

(:durative-action Drop
 :parameters (?h - hoist ?c - crate ?s - surface)
 :duration (= ?duration 1)
 :condition (and (at start (lifting ?h ?c))
                 (at start (clear ?s)))
 :effect (and (at start (not (lifting ?h ?c)))
              (at end (on ?c ?s))
              (at end (available ?h))))

(:durative-action Load
 :parameters (?h - hoist ?c - crate ?t - truck)
 :duration (= ?duration 3)
 :condition (at start (lifting ?h ?c))
 :effect (and (at start (not (lifting ?h ?c)))
              (at end (in ?c ?t))
              (at end (available ?h))))

(:durative-action Unload
 :parameters (?h - hoist ?c - crate ?t - truck ?s - surface)
 :duration (= ?duration 4)
 :condition (and (at start (in ?c ?t))
                 (at start (available ?h))
                 (at start (clear ?s)))
 :effect (and (at start (not (in ?c ?t)))
              (at start (not (available ?h)))
              (at end (lifting ?h ?c))
              (at end (on ?c ?s))
              (at end (available ?h))))

)
