from openai import OpenAI
import json


with open("OPENAI_KEY.json", 'r') as json_file:
        data = json.load(json_file)
        client = OpenAI(api_key=data['openai_key'])
        
prompt_text = """
Modify the following PDDL to include the following:
states: 
- lights
tools:
- light switch (not movable)
effects:
- using light switch toggles the state of the lights between true and false

(define (domain robotic-domain)
  (:requirements :fluents :strips :typing)

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

In order to be used tools must be at same location as robot. tools cannot be locations. States cannot be locations.
For any new actions you define start them with the 'USE_' token which must be capitalized.
"""


completion = client.chat.completions.create(model="gpt-4-turbo",
messages=[{
    "role": "system",
    "content": "You are a PDDL domain creation expert, you modify domains based on changes in the environment."
}, {
    "role": "user",
    "content": prompt_text}]
)


print(completion.choices[0].message.content)
