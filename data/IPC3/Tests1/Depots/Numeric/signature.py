class Place:
    def __init__(self, name):
        self.name = name

class Locatable:
    def __init__(self, name):
        self.name = name
        self.location = None

class Truck(Locatable):
    def __init__(self, name, load_limit):
        super().__init__(name)
        self.load_limit = load_limit
        self.current_load = 0

class Hoist(Locatable):
    def __init__(self, name):
        super().__init__(name)
        self.available = True
        self.lifting = None

class Surface(Locatable):
    def __init__(self, name):
        super().__init__(name)
        self.clear = True

class Pallet(Surface):
    pass

class Crate(Surface):
    def __init__(self, name, weight):
        super().__init__(name)
        self.weight = weight

class Environment:
    def __init__(self):
        self.fuel_cost = 0
        # Initialize other required attributes for the environment here
        self.locations = {}  # Dictionary to track locations of objects

    def at(self, locatable, place):
        return locatable.location == place

    def on(self, crate, surface):
        return crate.location == surface

    def in_truck(self, crate, truck):
        return crate in truck.crates

    def lifting(self, hoist, crate):
        return hoist.lifting == crate

    def available(self, hoist):
        return hoist.available

    def clear(self, surface):
        return surface.clear

    def load_limit(self, truck):
        return truck.load_limit

    def current_load(self, truck):
        return truck.current_load

    def weight(self, crate):
        return crate.weight

    def increase_fuel_cost(self, amount):
        self.fuel_cost += amount

    def decrease_fuel_cost(self, amount):
        self.fuel_cost -= amount

    def drive(self, truck, from_place, to_place):
        assert self.at(truck, from_place), "Precondition failed: Truck is not at the starting place."
        # Execute action
        truck.location = to_place
        self.increase_fuel_cost(10)
        # Check effects
        assert not self.at(truck, from_place), "Effect failed: Truck is still at the starting place."
        assert self.at(truck, to_place), "Effect failed: Truck is not at the destination place."

    def lift(self, hoist, crate, surface, place):
        assert self.at(hoist, place), "Precondition failed: Hoist is not at the place."
        assert self.available(hoist), "Precondition failed: Hoist is not available."
        assert self.at(crate, place), "Precondition failed: Crate is not at the place."
        assert self.on(crate, surface), "Precondition failed: Crate is not on the surface."
        assert self.clear(crate), "Precondition failed: Crate is not clear."
        # Execute action
        crate.location = None
        hoist.lifting = crate
        hoist.available = False
        surface.clear = True
        self.increase_fuel_cost(1)
        # Check effects
        assert not self.at(crate, place), "Effect failed: Crate is still at the place."
        assert self.lifting(hoist, crate), "Effect failed: Hoist is not lifting the crate."
        assert not self.clear(crate), "Effect failed: Crate is clear."
        assert not self.available(hoist), "Effect failed: Hoist is available."
        assert self.clear(surface), "Effect failed: Surface is not clear."
        assert not self.on(crate, surface), "Effect failed: Crate is still on the surface."

    def drop(self, hoist, crate, surface, place):
        assert self.at(hoist, place), "Precondition failed: Hoist is not at the place."
        assert self.at(surface, place), "Precondition failed: Surface is not at the place."
        assert self.clear(surface), "Precondition failed: Surface is not clear."
        assert self.lifting(hoist, crate), "Precondition failed: Hoist is not lifting the crate."
        # Execute action
        hoist.available = True
        hoist.lifting = None
        crate.location = surface
        surface.clear = False
        crate.clear = True
        self.increase_fuel_cost(1)
        # Check effects
        assert self.available(hoist), "Effect failed: Hoist is not available."
        assert not self.lifting(hoist, crate), "Effect failed: Hoist is still lifting the crate."
        assert self.at(crate, surface), "Effect failed: Crate is not at the place."
        assert not self.clear(surface), "Effect failed: Surface is clear."
        assert self.clear(crate), "Effect failed: Crate is not clear."
        assert self.on(crate, surface), "Effect failed: Crate is not on the surface."

    def load(self, hoist, crate, truck, place):
        assert self.at(hoist, place), "Precondition failed: Hoist is not at the place."
        assert self.at(truck, place), "Precondition failed: Truck is not at the place."
        assert self.lifting(hoist, crate), "Precondition failed: Hoist is not lifting the crate."
        assert self.current_load(truck) + self.weight(crate) <= self.load_limit(truck), "Precondition failed: Load limit exceeded."
        # Execute action
        hoist.lifting = None
        crate.location = truck
        hoist.available = True
        truck.current_load += self.weight(crate)
        self.increase_fuel_cost(1)
        # Check effects
        assert not self.lifting(hoist, crate), "Effect failed: Hoist is still lifting the crate."
        assert self.in_truck(crate, truck), "Effect failed: Crate is not in the truck."
        assert self.available(hoist), "Effect failed: Hoist is not available."
        assert self.current_load(truck) == self.current_load(truck), "Effect failed: Current load is incorrect."

    def unload(self, hoist, crate, truck, place):
        assert self.at(hoist, place), "Precondition failed: Hoist is not at the place."
        assert self.at(truck, place), "Precondition failed: Truck is not at the place."
        assert self.available(hoist), "Precondition failed: Hoist is not available."
        assert self.in_truck(crate, truck), "Precondition failed: Crate is not in the truck."
        # Execute action
        hoist.lifting = crate
        crate.location = None
        hoist.available = False
        truck.current_load -= self.weight(crate)
        self.increase_fuel_cost(1)
        # Check effects
        assert not self.in_truck(crate, truck), "Effect failed: Crate is still in the truck."
        assert self.lifting(hoist, crate), "Effect failed: Hoist is not lifting the crate."
        assert not self.available(hoist), "Effect failed: Hoist is available."
        assert self.current_load(truck) == self.current_load(truck), "Effect failed: Current load is incorrect."