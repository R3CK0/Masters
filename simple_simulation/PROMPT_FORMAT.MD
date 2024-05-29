# Prompt Format

## Base Format
Modify the following PDDL to include the following:
### states:
- state 1
- state 2  
### tools:
- tool 1
- tool 2  
### effects:
- using *state* **keyword** (sets, rotates, increases, decreases, sets the location of) *tool or state* **keyword** (to, by) *value* **case dependant** (to a maximum, to a minimum) *value*  

### current domain

Tools cannot be locations.  
States cannot be locations.  
For any new actions you define start them with the 'USE_' token  
Use correct PDDL syntax and avoid negative preconditions.  
DO not use if since it does not exist in PDDL  
Respond with only the modified PDDL  

## Adding a set condition for a boolean state (works very well)

```
Modify the following PDDL to include the following:
states:
- charge
tools:
- charging-station (not movable)
effects:
- using the charging-station sets the charge state of the robot to true

(define (domain robotic-domain)
  (:requirements :adl :universal-preconditions)

  (:types
    location
    tool
    robot
  )

  (:predicates
    (at ?r - robot ?l - location)
    (has ?r - robot ?t - tool)
    (movable ?t - tool)
    (tool-at ?t - tool ?l - location)
  )

  (:action move_robot
    :parameters (?r - robot ?from - location ?to - location)
    :precondition (at ?r ?from)
    :effect (and (at ?r ?to)
                 (not (at ?r ?from)))
  )

  (:action move_robot_with_tool
      :parameters (?r - robot ?from - location ?to - location ?t - tool)
      :precondition (and (at ?r ?from) (has ?r ?t) (tool-at ?t ?from))
      :effect (and (at ?r ?to)
                  (not (at ?r ?from))
                  (tool-at ?t ?to)
                  (not (tool-at ?t ?from)))
  )

  (:action pickup_object
    :parameters (?r - robot ?t - tool ?l - location)
    :precondition (and (at ?r ?l) (tool-at ?t ?l) (movable ?t))
    :effect (and (has ?r ?t) (not (tool-at ?t ?l)))
  )

  (:action drop_object
    :parameters (?r - robot ?t - tool ?l - location)
    :precondition (and (at ?r ?l) (has ?r ?t))
    :effect (and (not (has ?r ?t)) (tool-at ?t ?l))
  )
)

Example:
states:
- Power plant operational status
tools:
power button
effects:
using the power button toggles the power plant operational status between true and false


(:types
location
robot
tool
power_button - tool
)

(:predicates
(at ?r - robot ?l - location)
(tool-at ?t - tool ?l - location)
(power-on)
(power-off)
)

(:action USE_power_button_off
:parameters (?r - robot ?b - power_button ?l - location)
:preconditions (and (power-on) (at ?r ?l) (tool-at ?b ?l))
:effect (and (not (power-on)) (power-off))
)
(:action USE_power_button_on
:parameters (?r - robot ?b - power_button ?l - location)
:preconditions (and (power-off) (at ?r ?l) (tool-at ?b ?l))
:effect (and (power-on) (not (power-off)))
)

Tools cannot be locations.
States cannot be locations.
For any new actions you define start them with the 'USE_' token
Use correct PDDL syntax and avoid negative preconditions.
DO not use if since it does not exist in PDDL
Respond with only the modified PDDL
```

## Adding a toggle condition for a boolean state (Works ok, does not only output PDDL)

```
Modify the following PDDL to include the following:
states:
- sunlight
tools:
- earth-rotator (not movable)
effects:
- using the earth-rotator toggles the sunlight state between true and false

(define (domain robotic-domain)
  (:requirements :adl :universal-preconditions)

  (:types
    location
    tool
    robot
  )

  (:predicates
    (at ?r - robot ?l - location)
    (has ?r - robot ?t - tool)
    (movable ?t - tool)
    (tool-at ?t - tool ?l - location)
  )

  (:action move_robot
    :parameters (?r - robot ?from - location ?to - location)
    :precondition (at ?r ?from)
    :effect (and (at ?r ?to)
                 (not (at ?r ?from)))
  )

  (:action move_robot_with_tool
      :parameters (?r - robot ?from - location ?to - location ?t - tool)
      :precondition (and (at ?r ?from) (has ?r ?t) (tool-at ?t ?from))
      :effect (and (at ?r ?to)
                  (not (at ?r ?from))
                  (tool-at ?t ?to)
                  (not (tool-at ?t ?from)))
  )

  (:action pickup_object
    :parameters (?r - robot ?t - tool ?l - location)
    :precondition (and (at ?r ?l) (tool-at ?t ?l) (movable ?t))
    :effect (and (has ?r ?t) (not (tool-at ?t ?l)))
  )

  (:action drop_object
    :parameters (?r - robot ?t - tool ?l - location)
    :precondition (and (at ?r ?l) (has ?r ?t))
    :effect (and (not (has ?r ?t)) (tool-at ?t ?l))
  )
)

Example:
states:
- Power plant operational status
tools:
power button
effects:
using the power button toggles the power plant operational status between true and false


(:types
location
robot
tool
power_button - tool
)

(:predicates
(at ?r - robot ?l - location)
(tool-at ?t - tool ?l - location)
(has ?r - robot ?t - tool)
(movable ?t - tool)
(power-on)
(power-off)
)

(:action USE_power_button_off
:parameters (?r - robot ?b - power_button ?l - location)
:preconditions (and (power-on) (at ?r ?l) (tool-at ?b ?l))
:effect (and (not (power-on)) (power-off))
)
(:action USE_power_button_on
:parameters (?r - robot ?b - power_button ?l - location)
:preconditions (and (power-off) (at ?r ?l) (tool-at ?b ?l))
:effect (and (power-on) (not (power-off)))
)

Tools cannot be locations.
States cannot be locations.
For any new actions you define start them with the 'USE_' token
Use correct PDDL syntax and avoid negative preconditions.
DO not use if since it does not exist in PDDL
Respond with only the modified PDDL
```

## Adding a set condition for a discrete state

```
Modify the following PDDL to include the following:
states:
- dancing-style
tools:
- dancing-teacher (not movable)
effects:
- using the dancing-teacher sets the dancing-style state to the desired dancing-style

(define (domain robotic-domain)
  (:requirements :adl :universal-preconditions)

  (:types
    location
    tool
    robot
  )

  (:predicates
    (at ?r - robot ?l - location)
    (has ?r - robot ?t - tool)
    (movable ?t - tool)
    (tool-at ?t - tool ?l - location)
  )

  (:action move_robot
    :parameters (?r - robot ?from - location ?to - location)
    :precondition (at ?r ?from)
    :effect (and (at ?r ?to)
                 (not (at ?r ?from)))
  )

  (:action move_robot_with_tool
      :parameters (?r - robot ?from - location ?to - location ?t - tool)
      :precondition (and (at ?r ?from) (has ?r ?t) (tool-at ?t ?from))
      :effect (and (at ?r ?to)
                  (not (at ?r ?from))
                  (tool-at ?t ?to)
                  (not (tool-at ?t ?from)))
  )

  (:action pickup_object
    :parameters (?r - robot ?t - tool ?l - location)
    :precondition (and (at ?r ?l) (tool-at ?t ?l) (movable ?t))
    :effect (and (has ?r ?t) (not (tool-at ?t ?l)))
  )

  (:action drop_object
    :parameters (?r - robot ?t - tool ?l - location)
    :precondition (and (at ?r ?l) (has ?r ?t))
    :effect (and (not (has ?r ?t)) (tool-at ?t ?l))
  )
)

Example:
states:
- color
tools:
- color-selector
effects:
- using the color-selector sets the color state to de desired color

(:types
location
robot
tool
color
color-selector - tool
)

(:predicates
(at ?r - robot ?l - location)
(tool-at ?t - tool ?l - location)
(movable ?t - tool)
(selected-color ?c - color)
(unselected-color ?c - color)
)

(:action USE_unselect_color
:parameters (?r - robot ?c - color ?cs - color-selector ?l - location)
:preconditions (and (at ?r ?l) (tool-at ?cs ?l))
:effect (and (not (selected-color ?c)) (unselected-color ?c))
)
(:action USE_select_color
:parameters (?r - robot ?c - color ?cs - color-selector ?l - location)
:preconditions (and (at ?r ?l) (tool-at ?b ?l)
(forall (?co - color) (unselected-color ?co)))
:effect (and (selected-color ?c) (not (unselected-color ?c)))
)

Tools cannot be locations.
States cannot be locations.
For any new actions you define start them with the 'USE_' token
Use correct PDDL syntax and avoid negative preconditions.
DO not use if since it does not exist in PDDL
Respond with only the modified PDDL
```

## Adding increase condition for a range state

```
Modify the following PDDL to include the following:
states:
- credits
tools:
- bank (not movable)
effects:
- using the bank increases the credits state by 5

(define (domain robotic-domain)
  (:requirements :adl :universal-preconditions :fluents)

  (:types
    location
    tool
    robot
  )

  (:predicates
    (at ?r - robot ?l - location)
    (has ?r - robot ?t - tool)
    (movable ?t - tool)
    (tool-at ?t - tool ?l - location)
  )

  (:action move_robot
    :parameters (?r - robot ?from - location ?to - location)
    :precondition (at ?r ?from)
    :effect (and (at ?r ?to)
                 (not (at ?r ?from)))
  )

  (:action move_robot_with_tool
      :parameters (?r - robot ?from - location ?to - location ?t - tool)
      :precondition (and (at ?r ?from) (has ?r ?t) (tool-at ?t ?from))
      :effect (and (at ?r ?to)
                  (not (at ?r ?from))
                  (tool-at ?t ?to)
                  (not (tool-at ?t ?from)))
  )

  (:action pickup_object
    :parameters (?r - robot ?t - tool ?l - location)
    :precondition (and (at ?r ?l) (tool-at ?t ?l) (movable ?t))
    :effect (and (has ?r ?t) (not (tool-at ?t ?l)))
  )

  (:action drop_object
    :parameters (?r - robot ?t - tool ?l - location)
    :precondition (and (at ?r ?l) (has ?r ?t))
    :effect (and (not (has ?r ?t)) (tool-at ?t ?l))
  )
)

Example:
states:
- grade
tools:
- study (not movable)
effects:
- using the study increases the grade by 5 to a maximum of 100

(:types
location
robot
tool
study - tool
)

(:functions
(grade)
)

(:predicates
(at ?r - robot ?l - location)
(tool-at ?t - tool ?l - location)
(movable ?t - tool)
)

(:action USE_study
:parameters (?r - robot ?s - study ?l - location)
:preconditions (and (at ?r ?l) (tool-at ?s ?l) (<= (grade) 95))
:effect (and (increase (grade) 5))
)

Tools cannot be locations.
States cannot be locations.
For any new actions you define start them with the 'USE_' token
Use correct PDDL syntax and avoid negative preconditions.
DO not use if since it does not exist in PDDL
Respond with only the modified PDDL
```

## Adding decrease condition for a range state

```
Modify the following PDDL to include the following:
states:
- credits
tools:
- bank (not movable)
effects:
- using the bank decreases the credits state by 5 to a minimum of 10

(define (domain robotic-domain)
  (:requirements :adl :universal-preconditions :fluents)

  (:types
    location
    tool
    robot
  )

  (:predicates
    (at ?r - robot ?l - location)
    (has ?r - robot ?t - tool)
    (movable ?t - tool)
    (tool-at ?t - tool ?l - location)
  )

  (:action move_robot
    :parameters (?r - robot ?from - location ?to - location)
    :precondition (at ?r ?from)
    :effect (and (at ?r ?to)
                 (not (at ?r ?from)))
  )

  (:action move_robot_with_tool
      :parameters (?r - robot ?from - location ?to - location ?t - tool)
      :precondition (and (at ?r ?from) (has ?r ?t) (tool-at ?t ?from))
      :effect (and (at ?r ?to)
                  (not (at ?r ?from))
                  (tool-at ?t ?to)
                  (not (tool-at ?t ?from)))
  )

  (:action pickup_object
    :parameters (?r - robot ?t - tool ?l - location)
    :precondition (and (at ?r ?l) (tool-at ?t ?l) (movable ?t))
    :effect (and (has ?r ?t) (not (tool-at ?t ?l)))
  )

  (:action drop_object
    :parameters (?r - robot ?t - tool ?l - location)
    :precondition (and (at ?r ?l) (has ?r ?t))
    :effect (and (not (has ?r ?t)) (tool-at ?t ?l))
  )
)

Example:
states:
- grade
tools:
- procrastinate (not movable)
effects:
- using the procrastinate decreases the grade by 5 to a minimum of 0

(:types
location
robot
tool
procrastinate - tool
)

(:functions
(grade)
)

(:predicates
(at ?r - robot ?l - location)
(tool-at ?t - tool ?l - location)
(movable ?t - tool)
)

(:action USE_study
:parameters (?r - robot ?s - procrastinate ?l - location)
:preconditions (and (at ?r ?l) (tool-at ?s ?l) (>= (grade) 5))
:effect (and (decrease (grade) 5))
)

Tools cannot be locations.
States cannot be locations.
For any new actions you define start them with the 'USE_' token
Use correct PDDL syntax and avoid negative preconditions.
DO not use if since it does not exist in PDDL
Respond with only the modified PDDL
```


## Adding set condition for a range state

```
Modify the following PDDL to include the following:
states:
- credits
tools:
- bank (not movable)
effects:
- using the bank sets the credits state to 50

(define (domain robotic-domain)
  (:requirements :adl :universal-preconditions :fluents)

  (:types
    location
    tool
    robot
  )

  (:predicates
    (at ?r - robot ?l - location)
    (has ?r - robot ?t - tool)
    (movable ?t - tool)
    (tool-at ?t - tool ?l - location)
  )

  (:action move_robot
    :parameters (?r - robot ?from - location ?to - location)
    :precondition (at ?r ?from)
    :effect (and (at ?r ?to)
                 (not (at ?r ?from)))
  )

  (:action move_robot_with_tool
      :parameters (?r - robot ?from - location ?to - location ?t - tool)
      :precondition (and (at ?r ?from) (has ?r ?t) (tool-at ?t ?from))
      :effect (and (at ?r ?to)
                  (not (at ?r ?from))
                  (tool-at ?t ?to)
                  (not (tool-at ?t ?from)))
  )

  (:action pickup_object
    :parameters (?r - robot ?t - tool ?l - location)
    :precondition (and (at ?r ?l) (tool-at ?t ?l) (movable ?t))
    :effect (and (has ?r ?t) (not (tool-at ?t ?l)))
  )

  (:action drop_object
    :parameters (?r - robot ?t - tool ?l - location)
    :precondition (and (at ?r ?l) (has ?r ?t))
    :effect (and (not (has ?r ?t)) (tool-at ?t ?l))
  )
)

Example:
states:
- grade
tools:
- study (not movable)
effects:
- using the procrastinate sets the grade state to 90

(:types
location
robot
tool
study - tool
)

(:functions
(grade)
)

(:predicates
(at ?r - robot ?l - location)
(tool-at ?t - tool ?l - location)
(movable ?t - tool)
)

(:action USE_study
:parameters (?r - robot ?s - study ?l - location)
:preconditions (and (at ?r ?l) (tool-at ?s ?l))
:effect (and (assign (grade) 90))
)

Tools cannot be locations.
States cannot be locations.
For any new actions you define start them with the 'USE_' token
Use correct PDDL syntax and avoid negative preconditions.
DO not use if since it does not exist in PDDL
Respond with only the modified PDDL
```

## Creating an object

```
Modify the following PDDL to include the following:
states:
- hunger
tools:
- store (not movable)
- food (movable)
effects:
- using the store decreases credits by 5 and sets the location of food object to the location of the store
- using the food sets the hunger state to false

(define (domain robotic-domain)
  (:requirements :adl :universal-preconditions :fluents)

  (:types
    location
    tool
    robot
    bank - tool
  )

  (:functions
  (credits)
  )

  (:predicates
    (at ?r - robot ?l - location)
    (has ?r - robot ?t - tool)
    (movable ?t - tool)
    (tool-at ?t - tool ?l - location)
  )

  (:action move_robot
    :parameters (?r - robot ?from - location ?to - location)
    :precondition (at ?r ?from)
    :effect (and (at ?r ?to)
                 (not (at ?r ?from)))
  )

  (:action move_robot_with_tool
      :parameters (?r - robot ?from - location ?to - location ?t - tool)
      :precondition (and (at ?r ?from) (has ?r ?t) (tool-at ?t ?from))
      :effect (and (at ?r ?to)
                  (not (at ?r ?from))
                  (tool-at ?t ?to)
                  (not (tool-at ?t ?from)))
  )

  (:action pickup_object
    :parameters (?r - robot ?t - tool ?l - location)
    :precondition (and (at ?r ?l) (tool-at ?t ?l) (movable ?t))
    :effect (and (has ?r ?t) (not (tool-at ?t ?l)))
  )

  (:action drop_object
    :parameters (?r - robot ?t - tool ?l - location)
    :precondition (and (at ?r ?l) (has ?r ?t))
    :effect (and (not (has ?r ?t)) (tool-at ?t ?l))
  )

  (:action use_bank
    :parameters (?r - robot ?b - bank ?l - location)
    :precondition (and (at ?r ?l) (tool-at ?b ?l) (<= (credits) 995))
    :effect (and (increase (credits) 5))
  )
)

Tools cannot be locations.
States cannot be locations.
For any new actions you define start them with the 'USE_' token
Use correct PDDL syntax and avoid negative preconditions.
DO not use if since it does not exist in PDDL
Respond with only the modified PDDL
```

