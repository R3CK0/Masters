from game_front_end import PlanningSim
import pygame

class Sim_API:

    def __init__(self, simulation):
        self.sim = simulation
    
    #Since testing with only one agent using default name from simulation class as parameter for agents          
    def move_agent(self, agent, from_location, to_location):
        assert agent in list(self.sim.agents.keys()), "Agent does not exist"
        assert from_location in list(self.sim.locations.keys()), "From location does not exist"
        assert to_location in list(self.sim.locations.keys()), "To location does not exist"
        assert from_location == self.sim.agents[self.sim.default_name].location, "Agent is not at from location"
        
        self.sim.move_agent(to_location)
        
    def move_agent_with_tool(self, agent, object_name, from_location, to_location):
        assert object_name in list(self.sim.objects.keys()), "Object does not exist"
        assert object_name in [obj.name for obj in self.sim.agents[self.sim.default_name].inventory], "Agent is not carrying object"
        
        self.move_agent(agent, from_location, to_location)
    
    def pickup_object(self, agent, object_name, location):
        assert agent in list(self.sim.agents.keys()), "Agent does not exist"
        assert location in list(self.sim.locations.keys()), "Location does not exist"
        assert location == self.sim.agents[self.sim.default_name].location, "Agent is not at location"
        assert object_name in list(self.sim.objects.keys()), "Object does not exist"
        assert location == self.sim.objects[object_name].location, "Object is not at location"
        assert self.sim.objects[object_name].movable, "Object is not pickupable"
        
        self.sim.pickup_object(object_name)
    
    def drop_object(self, agent, object_name, location):
        assert agent in list(self.sim.agents.keys()), "Agent does not exist"
        assert location in list(self.sim.locations.keys()), "Location does not exist"
        assert object_name in list(self.sim.objects.keys()), "Object does not exist"
        assert object_name in [obj.name for obj in self.sim.agents[self.sim.default_name].inventory], "Agent is not carrying object"
        
        self.sim.drop_object(object_name)
    
    def use_object(self, agent, object_name, location):
        assert agent in list(self.sim.agents.keys()), "Agent does not exist"
        assert location in list(self.sim.locations.keys()), "Location does not exist"
        assert object_name in list(self.sim.objects.keys()), "Object does not exist"
        assert location == self.sim.objects[object_name].location, "Object is not at location"
        assert location == self.sim.agents[self.sim.default_name].location, "Agent is not at location"      
        
        self.sim.use_object(object_name)
    
    
    #For Human control 
    def handle_events(self, events):
        for event in events:
            if event.type == pygame.MOUSEBUTTONDOWN:
                if event.button == 1: #Left click
                    location = self.sim.get_clicked_location(pygame.mouse.get_pos())
                    if location is not None:
                        print("Selected location: ", location)
                        
            elif event.type == pygame.KEYDOWN:
                    if event.key == pygame.K_m:
                        if self.sim.selected_cell is not None:
                            location = self.sim.get_location_from_position(self.sim.selected_cell)
                            self.sim.move_agent(location)
                            self.sim.reset_selection()
                    elif event.key == pygame.K_o:
                        self.sim.object_selection()
                    elif event.key == pygame.K_DOWN:
                        self.sim.select_next_item()
                    elif event.key == pygame.K_UP:
                        self.sim.select_previous_item()
                    elif event.key == pygame.K_p:
                        self.sim.pickup_object(self.sim.get_selected_item())
                    elif event.key == pygame.K_i:
                        self.sim.inventory_selection()
                    elif event.key == pygame.K_d:
                        self.sim.drop_object(self.sim.get_selected_item())
                    elif event.key == pygame.K_u:
                        self.sim.use_object(self.sim.get_selected_item())
                    elif event.key == pygame.K_ESCAPE:
                        self.sim.reset_selection()
                    
            elif event.type == pygame.QUIT:
                self.sim.running = False
                    