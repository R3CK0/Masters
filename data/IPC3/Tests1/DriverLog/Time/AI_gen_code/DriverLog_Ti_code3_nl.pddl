(define (domain driverlog)
  (:requirements :typing :durative-actions :fluents) 
  (:types 
          location locatable - object
	  driver truck obj - locatable)
  (:predicates 
	(at ?obj - locatable ?loc - location)
	(in ?obj1 - obj ?obj - truck)
	(driving ?d - driver ?v - truck)
	(link ?x ?y - location)
        (path ?x ?y - location)
	(empty ?v - truck)
  )
  (:functions 
	(time-to-walk ?loc ?loc1 - location)
	(time-to-drive ?loc ?loc1 - location)
  )

  (:durative-action DRIVE-TRUCK
    :parameters
     (?truck - truck
      ?loc-from - location
      ?loc-to - location
      ?driver - driver)
    :duration (= ?duration (time-to-drive ?loc-from ?loc-to))
    :condition
     (and (at start (at ?truck ?loc-from))
     (over all (driving ?driver ?truck))
     (at start (link ?loc-from ?loc-to)))
    :effect
     (and (at start (not (at ?truck ?loc-from))) 
	  (at end (at ?truck ?loc-to)))
  )

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
  
  (:durative-action BOARD-TRUCK
    :parameters
     (?driver - driver
      ?truck - truck
      ?loc - location)
    :duration (= ?duration 1)
    :condition
     (and (at start (at ?driver ?loc))
	  (at start (at ?truck ?loc))
	  (at start (empty ?truck)))
    :effect
     (and (at end (driving ?driver ?truck))
	  (at end (not (empty ?truck)))
	  (at start (not (at ?driver ?loc)))))
   
  (:durative-action DISEMBARK-TRUCK
    :parameters
     (?driver - driver
      ?truck - truck
      ?loc - location)
    :duration (= ?duration 1)
    :condition
     (and (at start (driving ?driver ?truck))
	  (at start (at ?truck ?loc)))
    :effect
     (and (at end (at ?driver ?loc))
	  (at end (empty ?truck))
	  (at start (not (driving ?driver ?truck)))))

  (:durative-action LOAD-TRUCK
    :parameters
     (?obj - obj
      ?truck - truck
      ?loc - location)
    :duration (= ?duration 2)
    :condition
     (and (at start (at ?obj ?loc))
	  (at start (at ?truck ?loc)))
    :effect
     (and (at end (in ?obj ?truck))
	  (at start (not (at ?obj ?loc)))))
  
  (:durative-action UNLOAD-TRUCK
    :parameters
     (?obj - obj 
      ?truck - truck
      ?loc - location)
    :duration (= ?duration 2)
    :condition
     (and (at start (in ?obj ?truck))
	  (at start (at ?truck ?loc)))
    :effect
     (and (at end (at ?obj ?loc))
	  (at start (not (in ?obj ?truck)))))
)
