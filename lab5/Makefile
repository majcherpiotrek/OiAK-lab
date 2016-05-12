all:
	@echo "Kompilacja..."
	gcc -Wall -pg -g -o lab5 lab5.c calka.s calkaSSf.s calkaSSd.s calkaSIMD_f.s calkaSIMD_d.s set_fpu.s
test: lab5
	@echo "Test:"
	./lab5
prof:
	@echo "Tworzenie pliku z wynikami profilowania (lab5_prof.txt):"
	./lab5
	gprof lab5 gmon.out > lab5_prof.txt
clean:
	@echo "Czyszczenie katalogu:"
	rm lab5
cleanprof:
	@echo "Usuwanie plików profilowania:"
	rm gmon.out
	rm lab5_prof.txt
