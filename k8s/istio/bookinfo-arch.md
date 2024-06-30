# Bookinfo Architecture

The Bookinfo sample application deployed is composed of four microservices.

- Productpage: Serves the homepage, populated using the details and reviews microservices.
- Details: Contains the book information.
- Reviews: Contains the book reviews. It uses the ratings microservice for the star rating.
- Ratings: Provides the book rating for a book review.

The deployment includes three versions of the reviews microservice to showcase different behavior and routing:

- Review v1 doesn’t call the ratings service, no stars.
- Review v2 calls the ratings service and displays each rating as 1 to 5 black stars.
- Review v3 calls the ratings service and displays each rating as 1 to 5 red stars.

All services communicate over HTTP using DNS for service discovery. An overview of the architecture is shown below.

Unbeknownst to the Bookinfo containers, the Envoy proxy sidecars have been injected next to each microservice and surreptitiously intercept all inbound and outbound Pod traffic. You can see each Bookinfo Pod now contains two containers.
