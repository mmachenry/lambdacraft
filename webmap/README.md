webmap
---

This directory contains a cronable Docker image that will download the world
data from a shared volume, spend a few hours turning it into overview maps for
the web, and then upload tens of gigabytes of data to the S3 bucket hosting
the overview maps. This could be cronned up on a daily or weekly basis
depending on needs.
