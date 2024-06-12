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
        :condition (and (at start (available ?h))
                        (at start (on ?c ?s))
                        (at start (clear ?s)))
        :effect (and (at start (not (on ?c ?s)))
                     (at start (lifting ?h ?c))
                     (at start (not (available ?h)))))
    
    (:durative-action Drop
        :parameters (?h - hoist ?c - crate ?s - surface)
        :duration (= ?duration 1)
        :condition (and (at start (lifting ?h ?c))
                        (at start (clear ?s)))
        :effect (and (at start (not (lifting ?h ?c)))
                     (at start (available ?h))
                     (at end (on ?c ?s))))
    
    (:durative-action Load
        :parameters (?h - hoist ?c - crate ?t - truck)
        :duration (= ?duration 3)
        :condition (and (at start (lifting ?h ?c))
                        (at start (at ?t ?p)))
        :effect (and (at start (not (lifting ?h ?c)))
                     (at start (available ?h))
                     (at end (in ?c ?t))))
    
    (:durative-action Unload
        :parameters (?h - hoist ?c - crate ?t - truck)
        :duration (= ?duration 4)
        :condition (and (at start (in ?c ?t))
                        (at start (available ?h))
                        (at start (at ?t ?p)))
        :effect (and (at start (lifting ?h ?c))
                     (at start (not (available ?h)))
                     (at end (not (in ?c ?t)))))
)
