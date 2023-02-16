CID = 01725740

# Installs Lato fonts
fonts:
	mkdir fonts/
	curl -X GET --user-agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36" "https://fonts.google.com/download?family=Lato" --output fonts/Lato.zip
	unzip fonts/Lato.zip -d fonts/
	rm fonts/Lato.zip

# Utility function for submitting my files to TurnitIn
package:
	mkdir temp-package-dir
	# move all the files tracked by git to this folder, maintaining the folder structure
	git ls-files | rsync -a --files-from=- --prune-empty-dirs . temp-package-dir
	cd temp-package-dir ; zip -r ../$(CID)-project-1.zip *
	# clean up
	rm -r temp-package-dir

# Creates the plots and builds the infographic
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
