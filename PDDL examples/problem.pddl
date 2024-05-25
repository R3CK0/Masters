(define (problem metricVehicle-example) 
(:domain metricVehicle)
(:objects
    truck car - vehicle
    Paris Berlin Rome Madrid - location 
)

(:init
    (at truck Rome)
    (at car Paris)
    (= (fuel-level truck) 100)
    (= (fuel-level car) 100)
    (accessible car Paris Berlin)
    (accessible car Berlin Rome)
    (accessible car Rome Madrid)
    (accessible truck Rome Paris)
    (accessible truck Rome Berlin)
    (accessible truck Paris Madrid)
    (= (fuel-required Paris Berlin) 40)
    (= (fuel-required Berlin Rome) 30)
    (= (fuel-required Rome Madrid) 50)
    (= (fuel-required Rome Paris) 35)
    (= (fuel-required Rome Berlin) 40)
    (= (fuel-required Berlin Paris) 40)
    (= (total-fuel-used) 0)
    (= (fuel-used car) 0)
    (= (fuel-used truck) 0)
)

(:goal (and
    (at truck Paris)
    (at car Rome)
))

;un-comment the following line if metric is needed
(:metric minimize (total-fuel-used))
)