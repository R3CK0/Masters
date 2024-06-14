import DriverLog

class DriverLogWrapper(DriverLog):

    def __init__(self, client):
      self.driver_log = DriverLog(client)

    def load_truck(self, obj, truck, location):
        assert truck.at == location
        assert obj.location == location

        obj.location = None
        obj.inside = truck

    def unload_truck(self, obj, truck, location):
        assert truck.at == location
        assert obj.inside == truck

        obj.location = location
        obj.inside = None

    def board_truck(self, driver, truck, location):
        assert driver.at == location
        assert truck.empty
        assert truck.at == location

        driver.driving = truck
        driver.location = None
        truck.empty = False
    
    def disembark_truck(self, driver, truck, location):
        assert driver.driving == truck
        assert truck.at == location

        driver.driving = None
        driver.location = location
        truck.empty = True

    def drive_truck(self, driver, truck, location_from, location_to):
        assert driver.driving == truck
        assert truck.at == location_from
        assert self.driver_log.link(location_from, location_to)

        truck.at = location_to

    def walk(self, driver, location_from, location_to):
        assert driver.at == location_from
        assert self.driver_log.path(location_from, location_to)

        driver.at = location_to