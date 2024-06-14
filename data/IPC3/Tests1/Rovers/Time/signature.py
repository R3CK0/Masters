import Rovers


class RoverWrapper(Rovers):

    def __init__(self, client):
        self.rover = Rovers(client)
    
    def navigate(self, rover, waypoint_from, waypoint_to):
        assert rover.at == waypoint_from
        assert self.rover.can_taverse(waypoint_from, waypoint_to)
        assert self.rover.visible(waypoint_from, waypoint_to)
        assert rover.available
        assert rover.energy >= 8
        
        rover.at = waypoint_from
        rover.energy -= 8

    def recharge(self, rover, waypoint, duration):
        assert rover.at == waypoint
        assert waypoint.in_sun
        assert rover.energy <= 80
        
        rover.energy += duration * rover.recharge_rate

    def sample_soil(self, rover, store, waypoint):
        assert rover.at == waypoint
        assert rover.energy >= 3
        assert waypoint.at_soil_sample
        assert rover.equipped_for_soil_analysis
        assert store.of == rover
        assert store.empty

        store.empty = False
        store.full = True
        rover.energy -= 3
        rover.have_soil_analysis = waypoint
        waypoint.at_soil_sample = False

    def sample_rock(self, rover, store, waypoint):
        assert rover.at == waypoint
        assert rover.energy >= 5
        assert waypoint.at_rock_sample
        assert rover.equipped_for_rock_analysis
        assert store.of == rover
        assert store.empty

        store.empty = False
        store.full = True
        rover.energy -= 5
        rover.have_rock_analysis = waypoint
        waypoint.at_rock_sample = False

    def drop(self, rover, store):
        assert store.of == rover
        assert store.full

        store.empty = True
        store.full = False

    def calibrate(self, rover, camera, objective, waypoint):
        assert rover.at == waypoint
        assert rover.energy >= 2
        assert rover.equipped_for_imaging
        assert camera.on_board == rover
        assert camera.calibrration_target == objective
        assert self.rover.visible_from(objective, waypoint)

        camera.calibrated = rover
        rover.energy -= 2
    
    def take_image(self, rover, waypoint, objective, camera, mode):
        assert camera.calibrated == rover
        assert camera.on_board == rover
        assert rover.equipped_for_imaging
        assert rover.at == waypoint
        assert rover.energy >= 1
        assert self.rover.supports(camera, mode)
        assert self.rover.visible_from(objective, waypoint)

        rover.energy -= 1
        camera.calibrated = None
        rover.have_image = (objective, mode)

    def communicate_soil_data(self, rover, lander, waypoint_rover, waypoint_lander, waypoint_soil):
        assert rover.at == waypoint_rover
        assert lander.at_lander == waypoint_lander
        assert rover.have_soil_analysis == waypoint_soil
        assert self.rover.visible(waypoint_rover, waypoint_lander)
        assert rover.available
        assert lander.channel_free
        assert rover.energy >= 4

        rover.energy -= 4
        waypoint_soil.communicated_soil_data = True

    def communicate_rock_data(self, rover, lander, waypoint_rover, waypoint_lander, waypoint_rock):
        assert rover.at == waypoint_rover
        assert lander.at_lander == waypoint_lander
        assert rover.have_rock_analysis == waypoint_rock
        assert self.rover.visible(waypoint_rover, waypoint_lander)
        assert rover.available
        assert lander.channel_free
        assert rover.energy >= 4

        rover.energy -= 4
        waypoint_rock.communicated_rock_data = True

    def communicate_image_data(self, rover, lander, waypoint_rover, waypoint_lander, objective, mode):
        assert rover.at == waypoint_rover
        assert lander.at_lander == waypoint_lander
        assert rover.have_image == (objective, mode)
        assert self.rover.visible(waypoint_rover, waypoint_lander)
        assert rover.available
        assert lander.channel_free
        assert rover.energy >= 6

        rover.energy -= 6
        rover.have_image = None
        objective.communicated_image_data.append(mode)

