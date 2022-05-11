import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_json('/Users/artniewski/julia/traveling-salesman-problem/jsons/results-kox.json', orient='records')
for tsp_problem in df:
    for result in df[tsp_problem]:
        kox = dict(sorted(result.items(), key=lambda key: int(key[0])))
        keys = list(kox.keys())
        values = list(kox.values())
        # print(keys)
        # print(values)

        plt.plot(kox.keys(), kox.values())
        # plt.yscale('log')
        # plt.minorticks_off()
    plt.title(tsp_problem)
    plt.show()
    plt.clf()
