CID = 01725740

fonts:
	mkdir fonts/
	curl -X GET --user-agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36" "https://fonts.google.com/download?family=Lato" --output fonts/Lato.zip
	unzip fonts/Lato.zip -d fonts/
	rm fonts/Lato.zip

clean:
	echo "TODO"
	cd reports/
	latexmk -c
	cd ..

package:
	mdkr temp-package-dir
	git ls-files | xargs cp -t temp-package-dir

infographic: fonts
	# make sure the csv is available, from which the plots are made
	test -s data/gdpr-compliancy-data-full.csv || { echo "The GDPR compliancy data CSV was not found! Run the SQL query before attempting to build the infographic."; exit 1; }
	# create the plots
	Rscript analyses/plotting/gdpr-violations-by-country.R
	Rscript analyses/plotting/websites-of-the-internet.R
	# convert the plots
	inkscape --export-pdf=outputs/internet-waffle.pdf outputs/internet-waffle.eps
	inkscape --export-pdf=outputs/gdpr-by-country.pdf outputs/gdpr-by-country.eps
	# compile the infographic and move a copy it to root (lualatex needed for the fontenc package)
	latexmk -pdf -lualatex -output-directory="reports/build/" -verbose -synctex=1 -shell-escape reports/infographic.tex
	cp reports/build/infographic.pdf $(CID)-submission.pdf
