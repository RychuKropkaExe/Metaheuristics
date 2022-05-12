import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from collections import defaultdict
import statistics as st
import pathlib


def main():
    for result_type in ["long0", "rand_tabu", "reverse", "swap"]:
        df = pd.read_json("results-" + result_type + ".json", orient='records')
        max_list_dict = dict()
        for tsp_problem, tsp_list in df.items():
            list_of_dictionaries = list(tsp_list)
            max_list = list()
            for d in list_of_dictionaries:
                for k, v in d.items():
                    if k == '100':
                        max_list.append(v)
            max_list_dict[tsp_problem] = max_list
        #wilcoxon_test(max_list_dict)


if __name__ == '__main__':
    main()
