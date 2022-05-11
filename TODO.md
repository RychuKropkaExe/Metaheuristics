1. Co najmniej 2 otoczenia [V]
2. Łącznie 7 wariantów [V]
3. Akceleracja co najmniej jednego otoczenia [V]
4. Jakaś metoda eksploracji [V]
5. Różny budżet obliczeniowy. Sprawdzić, czy nie występuje przypadkiem przekłamanie, wynikające ze zbyt małego lub zbyt dużego budżetu obliczeniowego(Wykres gwałtownie spada, ale później się wygładza, gdzie drugi spada cały czas z taką samą "prędkością") [V]
6. Urównoleglenie(Przypadkiem się to zrobi) [V]
7. Testy statystyczne(Wilcockson) [ ]
8. Skorzystanie z parameter tunera [V]



Wilcoksona -> Wyników, tylko że tak z 10, dla każdego czyli łącznie 100 tabu searchu
Bootstrap -> Te same wyniki
Wykresy zachowania w czasie, dla każdego osobno, czyli 10 tabu searchu


Warianty algorytmu:
Nasz algorytm występuje w następujących wariantach:
- Wariant, z otoczeniem wyznaczanym funkcją „reverse”
- Wariant, z otoczeniem wyznaczanym funkcją „swap”
- Wariant, z losowym rozmiarem listy tabu
- Wariant, z tablicowym rozmiarem listy tabu(z otrzymanych wyników z parameter tunera)
- Wariant z brakiem listy długoterminowej(sam shuffling)
- Wariant z losowym rozmiarem listy długoterminowej
- Wariant z Iteracyjnym warunkiem stopu
Instancje:
1. a280.tsp 	2. bier127.tsp 	3. burma14.tsp
4. ch150.tsp 	5. d493.tsp 		6. d657.tsp
7. eil101.tsp 	8. eil51.tsp 		9. eil76.tsp
10. fl417.tsp 
