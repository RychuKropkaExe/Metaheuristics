import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from collections import defaultdict
import statistics as st


def main():
    df = pd.read_json('results-long0.json', orient='records')
    all_avg_dict = dict()
    for tsp_problem, tsp_list in df.items():
        list_of_dictionaries = list(tsp_list)
        dd = defaultdict(list)
        avg_dict = dict()
        for d in list_of_dictionaries:
            for k, v in d.items():
                dd[k].append(v)
        for k, v in dd.items():
            avg_dict[int(k)] = int(np.floor(st.mean(v)))
        all_avg_dict[tsp_problem] = avg_dict
    print(all_avg_dict)

    for tsp_problem, tsp_list in df.items():
        for d in tsp_list:
            keys = [int(i) for i in d.keys()]
            keys = np.sort(keys)
            values = [d[str(i)] for i in keys]

            plt.yscale('log')
            plt.plot(keys, values)
        plt.title(tsp_problem)
        curr_dict = all_avg_dict[tsp_problem]
        keys = [int(i) for i in curr_dict.keys()]
        values = [curr_dict[i] for i in keys]
        plt.scatter(keys, values, c='black', zorder=10)
        plt.show()
        plt.clf()


if __name__ == '__main__':
    main()
