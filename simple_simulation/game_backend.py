from game_front_end import PlanningSim

class Sim_API:

    def __init__(self, simulation):
        self.sim = simulation
              
    def move_agent(self, agent, from_location, to_location):
        assert from_location in list(self.sim.locations.keys()), "From location does not exist"
        assert to_location in list(self.sim.locations.keys()), "To location does not exist"
        assert from_location == list(self.sim.agent_location.keys())[0], "Agent is not at from location"
        
        self.sim.move_agent(to_location)
    
    def pickup_object(self, agent, object_name, location):
        assert location in list(self.sim.locations.keys()), "Location does not exist"
        assert location == list(self.sim.agent_location.keys())[0], "Agent is not at location"
        assert object_name in list(self.sim.objects.keys()), "Object does not exist"
        assert location == self.sim.objects[object_name].location, "Object is not at location"
        
        self.sim.pickup_object(object_name)
    
    def drop_object(self, object_name):
        pass
    
    def use_object(self, object_name):
        pass