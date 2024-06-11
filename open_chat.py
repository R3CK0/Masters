from openai import OpenAI
import json


with open("OPENAI_KEY.json", 'r') as json_file:
        data = json.load(json_file)
        client = OpenAI(api_key=data['openai_key'])
        
prompt_text = """
Modify the following PDDL domain
Add BOARD-TRUCK action, DISEMBARK-TRUCK action and DRIVE-TRUCK which allows the driver to get in and out of the truck and be in driving position as well as to drive from one location to another

This requires adding 3 actions
actions: BOARD-TRUCK, DISEMBARK-TRUCK, DRIVE-TRUCK

actions:
BOARD-TRUCK:
parameters: driver truck location
conditions: truck and driver at the same location and the truck is empty
effect: truck is no longer empty, the driver is no longer at location and the driver is driving

DISEMBARK-TRUCK:
parameters: driver truck location
conditions: truck is at location and driver is driving the truck
effect: driver is no longer driving the truck, the driver is at the location and the truck is empty

DRIVE-TRUCK:
parameters: location, location, driver, truck
conditions: driver must be driving the truck, the truck must be at the start location and there must be a link between the start location and the end location
effect: truck is moved from the start location to the end location, the driven time is increased by the time-to-drive from start to end

(define (domain driverlog)
  (:requirements :typing :fluents) 
  (:types           location locatable - object
		driver truck obj - locatable)

  (:predicates 
		(at ?obj - locatable ?loc - location)
		(in ?obj1 - obj ?obj - truck)
		(driving ?d - driver ?v - truck)
		(link ?x ?y - location) (path ?x ?y - location)
		(empty ?v - truck)
)
  (:functions (time-to-walk ?l1 ?l2 - location)
		(time-to-drive ?l1 ?l2 - location)
		(driven)
		(walked))


(:action LOAD-TRUCK
  :parameters
   (?obj - obj
    ?truck - truck
    ?loc - location)
  :precondition
   (and (at ?truck ?loc) (at ?obj ?loc))
  :effect
   (and (not (at ?obj ?loc)) (in ?obj ?truck)))

(:action UNLOAD-TRUCK
  :parameters
   (?obj - obj
    ?truck - truck
    ?loc - location)
  :precondition
   (and (at ?truck ?loc) (in ?obj ?truck))
  :effect
   (and (not (in ?obj ?truck)) (at ?obj ?loc)))

(:action WALK
  :parameters
   (?driver - driver
    ?loc-from - location
    ?loc-to - location)
  :precondition
   (and (at ?driver ?loc-from) (path ?loc-from ?loc-to))
  :effect
   (and (not (at ?driver ?loc-from)) (at ?driver ?loc-to)
	(increase (walked) (time-to-walk ?loc-from ?loc-to))))

 
)
"""

print("sending promt to GPT-4o")
completion = client.chat.completions.create(model="gpt-4o",
messages=[{
    "role": "system",
    "content": "You are a PDDL domain creation expert, you modify domains based on requested changes."
}, {
    "role": "user",
    "content": prompt_text}]
)


print(completion)


