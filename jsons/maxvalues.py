import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from collections import defaultdict
import statistics as st
import pathlib


def main():
    for tsp_problem in ["a280.tsp", "bier127.tsp", "pcb1173.tsp", "ch150.tsp", "vm1084.tsp", "u1060.tsp", "eil101.tsp",
                        "eil51.tsp", "eil76.tsp", "fl417.tsp"]:
        for result_type in ["random_long_term_length",
                            "random_tabu_length",
                            "long_term_length_0"]:  # "reverse",  "swap",  "with_tuner_values", "without_aspiration",
            # , ]:
            df = pd.read_json("results-" + result_type + ".json", orient='records')
            name = '_vs_'.join(["random_long_term_length", "random_tabu_length", "long_term_length_0"])
            list_of_dictionaries = list(df[tsp_problem])
            dd = defaultdict(list)
            avg_dict = dict()
            for d in list_of_dictionaries:
                for k, v in d.items():
                    if k != '0':
                        dd[k].append(v)
            for k, v in dd.items():
                avg_dict[int(k)] = int(np.floor(st.mean(v)))
            keys = [int(i) for i in avg_dict.keys()]
            keys = np.sort(keys)
            values = [avg_dict[i] for i in keys]
            plt.title(tsp_problem + "  " + name)
            plt.plot(keys, values, label=result_type)
        plt.legend()
        plt.yscale('log')
        path = pathlib.Path("plots/" + tsp_problem)
        path.mkdir(parents=True, exist_ok=True)
        # plt.show()
        plt.savefig("plots/" + tsp_problem + "/" + name + ".png")
        plt.clf()


if __name__ == '__main__':
    main()
