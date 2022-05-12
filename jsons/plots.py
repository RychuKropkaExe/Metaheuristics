import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from collections import defaultdict
import statistics as st
import pathlib


def main():
    for result_type in ["reverse", "swap", "with_tuner_values", "without_aspiration", "random_tabu_length",
                        "random_long_term_length", "long_term_length_0"]:
        df = pd.read_json("results-" + result_type + ".json", orient='records')
        all_avg_dict = dict()
        for tsp_problem, tsp_list in df.items():
            list_of_dictionaries = list(tsp_list)
            dd = defaultdict(list)
            avg_dict = dict()
            for d in list_of_dictionaries:
                for k, v in d.items():
                    if k != '0':
                        dd[k].append(v)
            for k, v in dd.items():
                avg_dict[int(k)] = int(np.floor(st.mean(v)))
            all_avg_dict[tsp_problem] = avg_dict
        for tsp_problem, tsp_list in df.items():
            path = pathlib.Path("plots/" + tsp_problem)
            path.mkdir(parents=True, exist_ok=True)

            for d in tsp_list:
                keys = [int(i) for i in d.keys() if i != '0']
                keys = np.sort(keys)
                values = [d[str(i)] for i in keys]

                plt.yscale('log')
                plt.plot(keys, values)
            plt.title(tsp_problem + " - " + result_type)
            curr_dict = all_avg_dict[tsp_problem]
            keys = [int(i) for i in curr_dict.keys()]
            values = [curr_dict[i] for i in keys]
            plt.scatter(keys, values, c='black', s=10, zorder=10)
            plt.scatter(keys, values, c='white', s=1, zorder=10)
            plt.savefig("plots/" + tsp_problem + "/" + result_type + ".png")
            plt.clf()


if __name__ == '__main__':
    main()
