(define (problem sunlight-example) 
(:domain robotic-domain)
(:objects
    robot1 - robot
    Home - location
    john - dancing-teacher
    jazz pop swing - style
)

(:init
    (at robot1 Home)
    (tool-at john Home)
    (style-set jazz)
)

(:goal (and
    (style-set swing)
))
)
