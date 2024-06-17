(:action WALK
  :parameters
    (?driver - driver
     ?loc-from - location
     ?loc-to - location)
  :precondition
    (and (at ?driver ?loc-from) (path ?loc-from ?loc-to))
  :effect
    (and (not (at ?driver ?loc-from)) (at ?driver ?loc-to)))
