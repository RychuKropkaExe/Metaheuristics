1. Ulepszenie zapobiegania stagnacji [V}
2. Znalezienie GA odniesienia [V]:
    1. Create an initial population of P chromosomes (generation 0). - random_population
    2. Evaluate the fitness of each chromosome.   
    3. Select P parents from the current population via proportional selection (i.e.,
    the selection probability is proportional to the fitness).  roulette_wheel_selection
    4. Choose at random a pair of parents for mating. Exchange bit strings with
    the one-point crossover to create two offspring.    op_crossover
    5. Process each offspring by the mutation operator, and insert the resulting
    offspring in the new population. - swap_mutation
    6. Repeat steps 4 and 5 until all parents are selected and mated (P offspring
    are created).
    7. Replace the old population of chromosomes by the new one. - replace_old_gen
    8. Evaluate the fitness of each chromosome in the new population.
    9. Go back to step 3 if the number of generations is less than some upper
    bound. Otherwise, the final result is the best chromosome created during the
    search. 