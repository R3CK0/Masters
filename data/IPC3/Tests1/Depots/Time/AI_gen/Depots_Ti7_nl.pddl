(define (domain Depot)
    (:requirements :typing :durative-actions :fluents)
    
    (:types place locatable - object
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
        (distance ?x - place ?y - place)
        (speed ?t - truck)
        (weight ?c - crate)
        (power ?h - hoist))
    
    (:durative-action Drive
        :parameters (?x - truck ?y - place ?z - place) 
        :duration (= ?duration (/ (distance ?y ?z) (speed ?x)))
        :condition (and (at start (at ?x ?y)))
        :effect (and (at start (not (at ?x ?y))) (at end (at ?x ?z))))
    
    (:durative-action Lift
        :parameters (?h - hoist ?c - crate ?s - surface)
        :duration (= ?duration 1)
        :condition (and (at start (available ?h)) (at start (clear ?c)) (at start (on ?c ?s)) (at start (clear ?s)))
        :effect (and (at start (not (available ?h)))
                     (at start (lifting ?h ?c))
                     (at start (not (on ?c ?s)))
                     (at start (clear ?s))
                     (at end (lifting ?h ?c))))
    
    (:durative-action Drop
        :parameters (?h - hoist ?c - crate ?s - surface)
        :duration (= ?duration 1)
        :condition (and (at start (lifting ?h ?c)) (at start (clear ?s)))
        :effect (and (at start (not (clear ?s)))
                     (at start (not (lifting ?h ?c)))
                     (at end (available ?h))
                     (at end (on ?c ?s))
                     (at end (clear ?s))))
    
    (:durative-action Load
        :parameters (?h - hoist ?c - crate ?t - truck)
        :duration (= ?duration (/ (weight ?c) (power ?h)))
        :condition (and (at start (lifting ?h ?c)))
        :effect (and (at start (not (lifting ?h ?c)))
                     (at end (in ?c ?t))
                     (at end (available ?h))))
    
    (:durative-action Unload
        :parameters (?h - hoist ?c - crate ?t - truck)
        :duration (= ?duration (/ (weight ?c) (power ?h)))
        :condition (and (at start (in ?c ?t)) (at start (available ?h)))
        :effect (and (at start (not (in ?c ?t)))
                     (at start (lifting ?h ?c))
                     (at end (lifting ?h ?c))))
)
