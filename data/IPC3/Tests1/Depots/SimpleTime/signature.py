import depot

class DepotWrapper(depot):
    def __init__(self, client):
        self.depot = depot(client)
        
    def Drive(self, truck, place1, place2):
        assert truck.at == place1
        
        truck.at = place2
        
        self.depot.drive(truck, place2)
    
    def Lift(self, hoist, crate, surface, place):
        assert hoist.at == place
        assert hoist.available
        assert crate.at == place
        assert crate.on == surface
        assert crate.clear
        
        crate.clear = False
        crate.on = None
        crate.at = None
        hoist.available = False
        hoist.lifting = crate
        surface.clear = True
        
        self.depot.lift(hoist, crate)
    
    def Drop(self, hoist, crate, surface, place):
        assert hoist.at == place
        assert hoist.lifting == crate
        assert surface.at == place
        assert surface.clear
        
        hoist.lifting = None
        hoist.available = True
        crate.at = place
        crate.on = surface
        crate.clear = True
        surface.clear = False
        
        self.depot.drop(hoist, crate)
        
    def Load(self, hoist, crate, truck, place):
        assert hoist.at == place
        assert hoist.lifting == crate
        assert truck.at == place
        
        crate.inside = truck
        hoist.available = False
        hoist.lifting = None
        
        self.depot.load(hoist, crate, truck)
    
    def Unload(self, hoist, crate, truck, place):
        assert hoist.at == place
        assert hoist.available
        assert crate.inside == truck
        assert truck.at == place
        
        crate.inside = None
        hoist.available = False
        hoist.lifting = crate
        
        self.depot.unload(hoist, crate, truck)
        