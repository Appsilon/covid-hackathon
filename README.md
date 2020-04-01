# CoronaRank

## Inspiration

We discovered a number of problems particularly compelling in the current outbreak and we realised that they can be addressed using geolocation data. Specifically:

COVID-19 tests are a limited resource, and there’s not an obvious way to decide who should be tested.

Since few tests are being done, and partly because many infected people are asymptomatic, it’s difficult to know which areas to avoid.

Supply chain management is going to be extremely difficult moving forward and policymakers need information on the current potential hotspots where an outbreak might be imminent.

Finally, many young healthy people are ignoring social distancing guidance on the basis that they have a low personal risk. We need a way to illustrate how breaking isolation can affect communities.

Google’s PageRank algorithm ranks web pages based partly on their interactions and connections with other popular web pages. We’ve taken that idea and applied it to epidemiology. You can determine the likelihood of whether a person has been exposed to coronavirus by using geolocation data to analyze their interactions with others. We replicate this methodology in epidemiology with Markov Chain modeling.

The resulting CoronaRank is an algorithm that uses geolocation data, epidemiology data, self-reporting, and Markov Chain modeling to assess the likelihood of coronavirus exposure.

## What it does

We can use CoronaRank to generate heatmaps, showing high-risk areas to avoid, raise awareness about responsibility to the community and providing predictions about where hospitals might be overloaded in the future based on potential exposure.

An individual’s CoronaRank is the likelihood that they may be infected with COVID-19. Confirmed cases are assigned a CoronaRank of 1. Non-confirmed persons are assigned a CoronaRank of 0<x<1 based on the following factors:

    # of confirmed cases in a user’s location (Country, Region, etc)
    Self-reports of COVID-19 related symptoms
    Interactions or possible interactions with others based on geolocation data from the past two weeks obtained from phones

The more you travel to risky places, the higher your CoronaRank. The more high-rank people visit a place, the more risky it becomes.

## How I built it

We developed and used the CoronaRank algorithm to analyse Veraset geolocation data. The resulting model allows for providing the user with a risk score and a heat map view. These features were contained in a web app designed for use on smartphones.

Development process:

    We analysed geolocation data
    For now we only use Veraset data, but with time we will gather data from user uploads
    Veraset data for one day contains over 3Gb of data for over 1 million people - processing this data is non trivial
    We’ve used pagerank implementation in C++ to allow for fast computation and results in the limited time frame
    Algorithm: we treat each location and person as a separate node in the MC (non-directed) graph. We add an edge in the graph if a given person visited given location. We initialise the edges with weights based on NYT county-level data.
    Results of the algorithm look very promising - people with high CoronaRank visit lot of risky and busy places, people with low CoronaRank are far from the outbreaks and commute much less than the others.

## Challenges I ran into

The geolocation dataset we used to generate heat maps does not provide enough granularity. We are waiting for the providers to deliver more granular data.

The Google Takeout data cannot be easily utilised in a mobile app. This will be resolved in future versions of the app.

## What's next for CoronaRank

We plan to integrate Google Takeout into the app to make it fully user-specific in the coming days. We need to obtain cloud resources to make this app available to the general public.

We hope to partner with governmental and international institutions to get endorsement for the app and deliver it to the public. A long-term collaboration would help to turn the app into a comprehensive tool to educate the public and drive informed procurement policy for public institutions.

