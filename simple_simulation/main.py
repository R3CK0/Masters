import pygame
import sys
from game_backend import Sim_API
from game_front_end import PlanningSim

def main():
    pygame.init()
    sim = PlanningSim("open_world.json")
    api = Sim_API(sim)
    
    sim.init()
    
    while sim.running:
        events = sim.get_events()
        api.handle_events(events)
        sim.update()
    
    sim.exit()

if __name__ == "__main__":
    main()