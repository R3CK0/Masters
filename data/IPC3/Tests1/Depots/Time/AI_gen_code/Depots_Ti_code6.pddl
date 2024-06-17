(define (domain Depot)
  (:requirements :typing :durative-actions :fluents)
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

  (:functions (distance ?x - place ?y - place)
              (speed ?t - truck)
              (weight ?c - crate)
              (power ?h - hoist))

  ;; Drive action to move trucks between places
  (:durative-action Drive
    :parameters (?t - truck ?p1 - place ?p2 - place)
    :duration (= ?duration (/ (distance ?p1 ?p2) (speed ?t)))
    :condition (at start (at ?t ?p1))
    :effect (and (at end (at ?t ?p2))
                 (at start (not (at ?t ?p1)))))

  (:durative-action Lift
    :parameters (?x - hoist ?y - crate ?z - surface ?p - place)
    :duration (= ?duration 1)
    :condition (and (over all (at ?x ?p)) 
                    (at start (available ?x)) 
                    (at start (at ?y ?p)) 
                    (at start (on ?y ?z)) 
                    (at start (clear ?y)))
    :effect (and (at start (not (at ?y ?p))) 
                 (at start (lifting ?x ?y)) 
                 (at start (not (clear ?y))) 
                 (at start (not (available ?x))) 
                 (at start (clear ?z)) 
                 (at start (not (on ?y ?z)))))

  (:durative-action Drop
    :parameters (?x - hoist ?y - crate ?z - surface ?p - place)
    :duration (= ?duration 1)
    :condition (and (over all (at ?x ?p)) 
                    (over all (at ?z ?p)) 
                    (over all (clear ?z)) 
                    (over all (lifting ?x ?y)))
    :effect (and (at end (available ?x)) 
                 (at end (not (lifting ?x ?y))) 
                 (at end (at ?y ?p)) 
                 (at end (not (clear ?z))) 
                 (at end (clear ?y))
                 (at end (on ?y ?z))))

  ;; Load action to load a crate into a truck
  (:durative-action Load
    :parameters (?x - hoist ?y - crate ?t - truck ?p - place)
    :duration (= ?duration 1)
    :condition (and (over all (at ?x ?p)) 
                    (over all (at ?t ?p)) 
                    (over all (lifting ?x ?y)))
    :effect (and (at end (in ?y ?t)) 
                 (at end (available ?x)) 
                 (at end (not (lifting ?x ?y)))))

  ;; Unload action to unload a crate from a truck
  (:durative-action Unload
    :parameters (?x - hoist ?y - crate ?t - truck ?p - place)
    :duration (= ?duration 1)
    :condition (and (over all (at ?x ?p)) 
                    (over all (at ?t ?p)) 
                    (over all (available ?x)) 
                    (over all (in ?y ?t)))
    :effect (and (at end (available ?x)) 
                 (at end (lifting ?x ?y)) 
                 (at end (not (in ?y ?t)))))
)
