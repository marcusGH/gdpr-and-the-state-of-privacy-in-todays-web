# Title

TODO: Overview of project, brief introduction to dataset, due to size, stored in Google BigQuery and access through an R api

The infographic is based on the following 3 tables from the [HTTP Archive](https://httparchive.org/):

| Table Name                                        | Number of rows | Total logical bytes | Total physical bytes |
| --                                                | --             | --                  | --                   |
| `httparchive.summary_pages.2023_01_01_desktop`    | 12 675 392     | 12.27 GB            | 1.74 GB              |
| `httparchive.summary_requests.2023_01_01_desktop` | 1 187 819 093  | 1.37 TB             | 133.85 GB            |
| `httparchive.technologies.2023_01_01_desktop`     | 229 667 717    | 12.91 GB            | 2.83 GB              |

However, data from different snapshot dates can also easily be used by just changing the table names in [`config.yaml`](config.yaml). Since these tables are fairly large in size, it is recommended to query them using Google BigQuery instead of downloading them locally.


% TODO: table of the three tables, their sizes, and number of rows, quick explanation of why Big Query used

TODO: Table of Contents

## Repository overview


## Requirements

Before attempting to reproduce the infographic, please make sure you have all the following on your system:

* The R programming language
* The `R` packages found in [`install_requirements.R`](install_requirements.R).
  You can either run this script on your system or install them manually.
* The Lato font. For Linux and MacOS users, this can be configured by running
  `make fonts`. For Windows users, please install the [Lato font
  pack](https://fonts.google.com/specimen/Lato) and extract the files to
  `<PROJECT-ROOT>/fonts/`.
* A Google BigQuery billing key. See the instructions in [Acquiring a Google BigQuery billing key](#Acquiring-a-Google-BigQuery-billing-key) on how to obtain one.
* The following LaTeX packages: `geometry`, `graphicx`, `setspace`, `tcolorbox`, `float`, `hyperref`, `xcolor`, `moresize`, `array`, `tikz`, `lato`, and `fontspec`.
* If you want to compile the [`reports/infographic.tex`](reports/infographic.tex) using the [`Makefile`](Makefile), you will also need the following:
  * GNU Make
  * `curl` (for getting the fonts)
  * `inkscape` (you could alternatively use `epstopdf` instead, but I have not tested this)
  * `latexmk` with LuaTeX support

## Acquiring a Google BigQuery billing key

To access the data with the Google BigQuery R API, a billing key is required.
You do not need a credit card to set this up as Google BigQuery has a free tier
that allows up to 1TB of free data processing per month. To acquire your billing
key, you should do the following:
1. Create a Google account
2. Navigate to the [Google Cloud Projects Page](https://console.cloud.google.com/start), following relevant instructions if prompted. Once you have logged in, you should see a page like this:
  ![welcome page for Google Cloud projects](https://user-images.githubusercontent.com/29378769/218258002-3dbacd16-79a5-4104-8464-4d4c62122bd0.png)
3. Click on `Select a project` and create a new project with a name of your choice. Remember to note down the project ID of your created project. This will be used as the billing key.
4. Save the billing key to your `.Rprofile` file by adding `options(bigquery_billing_ID="MY-PROJECT-ID")`. If you are a Linux or MacOS user, this can be done with:
   ```
   BILLING_ID="MY-PROJECT-ID" ; echo "options(bigquery_billing_ID='${BILLING_ID}')" >> ~/.Rprofile
   ```
   Remember to replace `MY-PROJECT-ID` with the project ID of the project you created in step 3
5. To test that everything is working correctly, run [`src/data-fetching/test-bigquery-connection.R`](src/data-fetching/test-bigquery-connection.R). This will open an authentication window in your browser. After authenticating, you should see a list of 21 different table names in your R console.

## Fetching the data

TODO

fetch-gdpr-violation-data.R

> :warning: **This code will execute an expensive query that joins a table with 1 billion rows with another table containing 1 million rows, so it will use about 170 GB of your Google BigQuery processing quota**: Make sure you have at least this much credit available in your billing key before running this code.


Set your working directory to the root of the project.



## Discussion

Focus on websites using Google AdSense to deliver ads on their website
According to
[Google's AdSense Help site](https://support.google.com/adsense/answer/9007336?hl=en-GB),
both personalised and non-personalised advertisements requires the user's consent if
the website is hosted in a
[ePrivacy Directive](https://en.wikipedia.org/wiki/Privacy_and_Electronic_Communications_Directive_2002)-particpating
country. Therefore, websites found by the `httparchive` to use this technology should also
employ a Cookie Banner to acquire the user's consent. Otherwise, they would be violating these
rules.



https://www.cookiechoices.org/intl/en-GB/ needed?
https://ads.google.com/intl/en_uk/home/faq/gdpr/

## Blocklist

Could use
https://github.com/nickspaargaren/no-google

but covers to many, rather a few and 

