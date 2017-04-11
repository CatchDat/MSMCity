# MSMCity - Multi-level Microsimulation

Usage:

Obtain API keys for nomisweb.co.uk, graphhopper.com and transportapi.co

Define a character vector `regions` to cover the area in question, e.g.:

```
> regions=c("Newcastle upon Tyne", "North Tyneside", "Gateshead", "South Tyneside",
          "Sunderland")

```
for a metropolitan county, or 
```
> regions=c("Newcastle upon Tyne")

```
for a single local authority, or
```
> regions=c("Bradford 001")

```

for a single MSOA, or

```
> regions=allEnglandAndWales()

```

for a national-level microsimulation. (NB this will take time and may overload the APIs)


Run the simulation:

> source("./MSIM.R")
