clean:
	echo "TODO"
	cd reports/
	latexmk -c
	cd ..

package:
	git ls-files

infographic:
	latexmk -output-directory="reports/build/" -verbose reports/infographic.tex
