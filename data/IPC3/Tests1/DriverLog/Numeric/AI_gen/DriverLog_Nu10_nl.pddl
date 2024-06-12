(define (domain driverlog)
+ (define (domain driverlog)
  (:requirements :typing :fluents) 
  (:types           location locatable - object
        driver truck obj - locatable)

  (:predicates 
        (at ?obj - locatable ?loc - location)
        (in ?obj1 - obj ?obj - truck)
        (driving ?d - driver ?v - truck)
        (link ?x ?y - location)
        (empty ?v - truck)
  )
  (:functions (time-to-walk ?l1 ?l2 - location)
        (time-to-drive ?l1 ?l2 - location)
        (driven)
        (walked))
