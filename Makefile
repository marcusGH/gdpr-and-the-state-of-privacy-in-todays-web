CID = 01725740

clean:
	echo "TODO"
	cd reports/
	latexmk -c
	cd ..

package:
	git ls-files

infographic:
	# convert the plots
	inkscape --export-pdf=outputs/internet_waffle.pdf outputs/internet_waffle.eps
	inkscape --export-pdf=outputs/gdpr_by_country.pdf outputs/gdpr_by_country.eps
	# compile and export
	latexmk -pdf -lualatex -output-directory="reports/build/" -verbose -synctex=1 -shell-escape reports/infographic.tex
	cp reports/build/infographic.pdf $(CID)-submission.pdf
