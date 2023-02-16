# Do EU Websites Care About Your Consent?

This repository contains a reproducible report on the current state of
cookie banners and advertisements on the web, focusing on traffic
in GDPR-compliant countries.

Table of contents:
<!-- vim-markdown-toc GFM -->

* [Overview of dataset](#overview-of-dataset)
* [Repository overview](#repository-overview)
* [Requirements](#requirements)
* [Acquiring a Google BigQuery billing key](#acquiring-a-google-bigquery-billing-key)
* [Fetching the data](#fetching-the-data)
* [Producing the plots and infographics](#producing-the-plots-and-infographics)
* [Configuration](#configuration)
* [Methodology](#methodology)

<!-- vim-markdown-toc -->

To reproduce the [infographic](01725740-submission.pdf), do the following:
1. Make sure yours system satisfies all the [requirements](#Requirements), including a Google BigQuery billing key.
2. Fetch the data used for analysis by following the steps in [Fetching the data](#Fetching-the-data).
3. Produce the plots and compile the infographic by following the steps in [Producing the plots and infographics](#Producing-the-plots-and-infographics).

## Overview of dataset

Researchers at the [HTTP Archive](https://httparchive.org/) "periodically crawl
the top sites on the web and record detailed information about fetched
resources, used web platform APIs and features, and execution traces of each
page." The raw data is available through many different tables, all available
on [Google BigQuery](https://github.com/HTTPArchive/httparchive.org/blob/main/docs/gettingstarted_bigquery.md).
However, with the interest of this project being investigating GDPR compliant
websites and Internet traffic, only the following 3 tables are considered:

| Table Name                                        | Number of rows | Total logical bytes | Total physical bytes |
| --                                                | --             | --                  | --                   |
| `httparchive.summary_pages.2023_01_01_desktop`    | 12 675 392     | 12.27 GB            | 1.74 GB              |
| `httparchive.summary_requests.2023_01_01_desktop` | 1 187 819 093  | 1.37 TB             | 133.85 GB            |
| `httparchive.technologies.2023_01_01_desktop`     | 229 667 717    | 12.91 GB            | 2.83 GB              |

Since these tables are fairly large in size, it is recommended to query them
using Google BigQuery instead of downloading them locally, especially the `summary_requests` table.

The data of the above tables are from HTTP requests and websites recorded
between January 1st 2023 and Januray 16th 2023. To perform the same analysis on
a different data range, the table names can be changed in
[`config.yaml`](config.yaml). Consult the [Configuration section](#configuration) for more
information.

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

Run `src/data-fetching/fetch-gdpr-violation-data.R`

> :warning: **This code will execute an expensive query that joins a table with 1 billion rows with another table containing 1 million rows, so it will use about 170 GB of your Google BigQuery processing quota**: Make sure you have at least this much credit available in your billing key before running this code. :warning:

This will first inject the [`sql/templates/gdpr-compliancy-by-country-time-template.sql`](sql/templates/gdpr-compliancy-by-country-time-template.sql) query with the table names configured in [`config.yaml`](config.yaml). It will then parse the resulting query and make an API request to Google BigQuery with `bigrquery`. The resulting table is then saved as a `.csv` file in `data/`.

For more documentation on how the SQL query works, see [`sql/templates/gdpr-compliancy-by-country-time-template.sql`](sql/templates/gdpr-compliancy-by-country-time-template.sql). Also note that not all the columns in the resulting csv were used, only the `tld, num_requests, num_cookie_compliance, num_google_ads, num_google_ads_violations, num_unique_pages, num_unique_pages_legal_google_ads, num_unique_pages_with_cookie_compliance` and `num_unique_pages_with_google_ads` are used.

## Producing the plots and infographics

**Using the Makefile (recommended)**

Simply run `make infographic`. This will run the relevant R scripts to produce the plots, and convert them into a format that's readable by LaTeX, and then compile the LaTeX file [`reports/infographic.tex`](reports/infographic.tex) and copy the resulting infographic into the project root directory.

**Manually**

* Make sure the Lato `.ttf` files are in the `fonts/` folder in the project root directory by following the requirements instructions.
* Run [`analyses/plotting/gdpr-violations-by-country.R`](analyses/plotting/gdpr-violations-by-country.R) and [`analyses/plotting/websites-of-the-internet.R`](analyses/plotting/websites-of-the-internet.R) to create `.eps` files of the two visualisations in `outputs/`
* Convert the `.eps` files to `.pdf` using for example the `epstopdf` tool and save them in the `outputs/` folder with the same name
* Compile the LaTeX document [`reports/infographic.tex`](reports/infographic.tex). This has to be done using a XeLaTeX or LuaLaTeX compiler. PDFLaTeX cannot be used because it does not support the `fontspec` package.

## Configuration

To perform the same analysis as above on a different temporal snapshot of the
web, e.g. in 2017 before the GDPR became enforceable, you can change the tables
used in [`config.yaml`](config.yaml). The `full` tables are the ones that are
used for the analysis. The `small` tables are used for testing as querying
these costs far less BigQuery credits to be billed. To see the list of dates
available for the different tables, you can run the following after setting up
your billing key:

```R
library(bigrquery)
library(DBI)

con <- dbConnect(
  bigrquery::bigquery(),
  project = "httparchive",
  dataset = "summary_requests", # or "summary_pages", or "technologies"
  billing = getOption("bigquery_billing_ID")
)
dbListTables(con)
```

The `third_parties` key in [`config.yaml`](config.yaml) specifies a list of
substrings. If any HTTP requests is directed to a URL _containing_ any of
these, it is marked as a `is_third_party` requests by the SQL query. Columns
related to this attribute were not used in the final analysis. The default
values were found by visiting various news-websites with
[Ghostery](https://addons.mozilla.org/en-GB/firefox/addon/ghostery/) installed
and noting down the origin of the third-party trackers.

## Methodology

The aim of this project was to investigate and tell a story related to how GDPR is not always
complied with in countries where it is a legal requirement. To do this, a lot of care needs to
be taken to ensure that what is counted as GDPR violation, really is such a violation.
To do this we should only count instances where we can:
1. Ensure the requested website needs to follow the GDPR
2. Ensure the requested website uses cookies beyond those strictly necessary, and without consent

The first point is satisfied by only considering traffic directed to websites
with a top-level-domain of a EU member state, as this ensures the website is
_based_ in a GDPR-compliant country. We note that violations might also occur
for international websites, but we do not count these as we do not want to
count non-violation instances incorrectly.
To meet the second point, we use the HTTP Archive's `technologies` table to
check whether a website uses a cookie compliance banner and if the website uses
Google AdSense to deliver advertisements. Google AdSense was chosen because
(i) it is the most widely used technology for delivering online ads and (ii)
it requires cookie consent for both personalised and non-personalised ads:

> Although non-personalised ads don’t use cookies or mobile ad identifiers for ad targeting, they do still use cookies or mobile ad identifiers for frequency capping, aggregated ad reporting and to combat fraud and abuse. Therefore, you must obtain consent to use cookies for those purposes where legally required, per the ePrivacy Directive in certain EEA countries.

Source: [Google AdSense Help personalised and non-personalised ads](https://support.google.com/adsense/answer/9007336)

Despite the above measures being taken, we still note that the HTTP Archive's list of Cookie Consent banners might be lacking, in which case the violation count might be higher than it should be.
