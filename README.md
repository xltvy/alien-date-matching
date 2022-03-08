# alien-date-matching

Bogazici University

Computer Engineering Department

Spring 2021

CMPE 260 - Principles of Programming Languages

Project 1

Altay Acar

***

Using the functional programming language Prolog a date matching algorithm like Tinder for an alien nation called Glanians.

There is a knowledge base of .pro files containing information about the preferences of each individual:
- city.pro for cities and the available activities in there
- dislikes.pro for the disliked features for each individual
- expects.pro for the expectation preferences of each individual towards another
- glanian.pro for each individual's features
- likes.pro for the liked features for each individual
- old_relation.pro for the tracking of old relationships between Glanians
- weight.pro for the calculated weight for each individual

The code measures each distance between each individual for every feature, filters the candidates according to their cities, dislikes, likes and old relations. Using all these data, finds the best possible matches for each individual.
