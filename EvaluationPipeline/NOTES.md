# Notes

## Prompt engineering notes

* When adding a state due to the basic reasoning of the LLM it is difficult to get it do simply add the state to the domain without having it find a logical way to modify said state(predicate).  

* In order to simplifie some tools/objects/types it has a tendency to set them as locations.  

* Need to specify that the agent must be at the same location as an object to use. 

* Added `USE_` token before the new functions so that they can be quickly identified with parsing once plan is generated

* LLM seems to have some predisposition to using common sense reasoning such as assigning the hunger state to the robot instead of simply addind it globally for the domain.

* If not is found within a precondition add the `:negative-precondition` requirement. This does not work with the POPF planner, it will make the domain valid, however will not be able to find plan. Removing the negative precondition works. As well as having 2 states on/off instead of (on) and (not (on))

* GPT-4 tends to add if statements which are not taken into account in any PDDL requirement. Reprompt

## Dynamic issues

* In order to work with dynamic objects, unseen objects, simply load them into the world and unload them as they come, declaring a set of random objects 

* As Domains get bigger consider using RAG to only extract relevant actions

## How to deal with complex tasks and actions

* When asking robot to perform a task that requires multiple actions, for example: openning a drawer, clicking a button or flipping a switch. These would be the steps to accomplishing this.

![Automatic codebase updates](action_plan.drawio.png)


# Domain modifications

### Depot_numeric:  
- Remove load restrictions  
- Remove fuel restrictions  
-  there is now a maximum distance that a truck can travel before needing to  c  	refuel, this is based on each truck and depends on the volume of the 	gas tank the truck can refuel at any place but must be able to make it 	from place to the other with the fuel in the tank. The fuel cost per 	unit of distance increases based on the weight  
- Remove Drive action  
- Remove the lift and drop actions  
- Remove the Load and unload functions  

### Depot_durative:  
- Remove durative  
- change times from 10 1 1 3 4 to  1 1 1 1 1  
- remove drive  
- remove lift and drop  
- Remove load and unload  


### Driver_log_numeric:  
- Remove walk and time-to-walk  
- Removed driven and time-to-drive  
- Remove actions (1-5)  
- added increase/decrease speed and modified time-to-drive math  
- removed driving predicate  
- added tires-ok predicate  
- removed path predicate  
- added sober predicate  

### Driver_log_durative:  
- Remove actions (1-5)  
- Remove durative actions  
- changed all durations to 1  
- changed durations from 2 2 1 1 10 20 to 5 5 3 3 20 30  
- removed driving predicate  
- removed path predicate  
- added sober predicate  
- added tires-ok predicate  

### Driver_log_Strips:  
- Remove actions (1-5)  
- removed driving predicate  
- removed path predicate   
- added sober predicate  
- added tires-ok predicate  

### Driver_log_Time:  
- Remove actions (1-5)  
- Remove time-to-walk  
- Removed time-to-drive  
- added increase/decrease speed and modified time-to-drive math  
- Remove durative actions  
- changed all durations to 1  
- changed durations from 2 2 1 1 10 20 to 5 5 3 3 20 30  
- removed driving predicate  
- removed path predicate  
- added tires-ok predicate  
- added sober predicate  


### Zeno_numeric:   
- remove actions (1-5)  
- remove zoom-limit  
- removed slow and fast burn  
- added weight  
...  


### rovers_numeric:  
- remove actions (1-5)  
- remove recharge  
- remove energy and recharge  
- Remove visible  
- Remove channel-free  
- added long-range comms  
- added air-analysis  


### rovers_durative:  
- remove actions (1-5)  
- remove durative_actions  
- change all durations to 1  
- Remove visible  
- Remove channel-free  
- added long-range comms  
- added air-analysis  


### rovers_strips:  
- remove actions (1-5)  
- Remove visible  
- Remove channel-free  
- added long-range comms  
- added air-analysis  

### rovers_time:  
- remove actions (1-5)  
- remove recharge  
- remove energy and recharge  
- remove durative_actions  
- change all durations to 1  
- Remove visible  
- Remove channel-free  
- added long-range comms  
- added air-analysis  


## Prompt structure
- Ask to modify `Modify the Following PDDL domain`
- Abstracted modification (Natural language) Example: `Add weight limitation to the truck`
- Specify names and types of modified elements `This will require adding 3 functions: load_limit per truck, current_load per truck and weight per crate`
- 1. Specify exact modifications in actions to perform 

```
The load action will have an extra predicate where the load_limit for the truck must be lower then the current_load + the weight of the crate
The effect will have the current_weight increased by the crate weight
``` 
- For modifications to predicates or when possible add this kind of label as well
- 2. Let model try on its own `Modify the load and unload actions accordingly` 