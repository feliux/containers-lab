from apistar import Route

def custom_route(name: str=None):
    if name is None:
        name = "anonymous"
    return "Hello {name}, you got the power".format(**locals())

routes = [Route("/", method="GET", handler=custom_route),]
