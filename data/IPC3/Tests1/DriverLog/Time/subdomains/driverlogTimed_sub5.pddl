;Remove all actions except walk

(define (domain driverlog)
  (:requirements :typing :durative-actions :fluents) 
  (:types 
          location locatable - object
	driver truck obj - locatable)
  (:predicates 
		(at ?obj - locatable ?loc - location)
		(in ?obj1 - obj ?obj - truck)
		(driving ?d - driver ?v - truck)
		(link ?x ?y - location) (path ?x ?y - location)
		(empty ?v - truck)
)


(:functions (time-to-walk ?loc ?loc1 - location)
	    (time-to-drive ?loc ?loc1 - location))

(:durative-action WALK
  :parameters
   (?driver - driver
    ?loc-from - location
    ?loc-to - location)
  :duration (= ?duration (time-to-walk ?loc-from ?loc-to))
  :condition
   (and (at start (at ?driver ?loc-from)) 
	(at start (path ?loc-from ?loc-to)))
  :effect
   (and (at start (not (at ?driver ?loc-from)))
	(at end (at ?driver ?loc-to))))
 
)
